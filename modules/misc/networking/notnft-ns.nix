{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    types
    mkOption
    mkDefault
    mkEnableOption
    flip
    concatMapStringsSep
    optionalAttrs
    listToAttrs
    optional
    filter
    optionalString
    getExe
    getExe'
    mkIf
    mapAttrsToList
    mapAttrs
    mapAttrs'
    nameValuePair
    foldl
    mkBefore
    mkMerge
    ;
  notnft = inputs.notnft.lib.${pkgs.stdenv.system};
  cfg = config.networking.notnft;
  jsonFormat = pkgs.formats.json {};

  # Possible debug mode? execute nft one by one, and print when it fails
  #  cat /nix/store/6sk3qrp7vwwxyr773i3hpgfppc4qd4wf-rules.json | jq '.nftables | .[] | { nftables: [ . ] } ' -c | xargs -d'\n' -I {} sh -c $'sudo nft -j -f - <<<"$1"' sh {}

  jqSortingRule = ''
    {
      nftables: (
        .nftables |
          map(select(has("add") | not)) +
          map(select(.add | has("table"))) +
          map(select(.add | has("chain"))) +
          map(select(has("add") and (.add | has("chain") or has("table") | not)))
      )
    }
  '';
  jsonFile = namespace:
    (pkgs.writeTextFile {
      name = "rules-${namespace}.json";
      text = builtins.toJSON {
        nftables =
          (optional cfg.namespaces.${namespace}.flush {flush.ruleset = null;})
          ++ cfg.namespaces.${namespace}.preRules
          ++ cfg.namespaces.${namespace}.rules.nftables
          ++ cfg.namespaces.${namespace}.postRules;
      };
    })
    .overrideAttrs (old: {
      buildCommand =
        old.buildCommand
        + ''
          _tmpfile=$(mktemp)
          ${getExe pkgs.jq} '${jqSortingRule}' <$target >$_tmpfile

          _original_loc="$(${getExe pkgs.jq} '.nftables | length' <$target)"
          _sorted_loc="$(${getExe pkgs.jq} '.nftables | length' <$_tmpfile)"

          [ "$_original_loc" -eq "$_sorted_loc" ] || (
            echo "A command was dropped"
            cp $target ./out ; exit 1
          )
          mv $_tmpfile $target
        '';
    });

  rulesetBefore = rules: {
    nftables = mkBefore (notnft.dsl.ruleset rules).nftables;
  };

  notnftNamespace = {config, ...}: {
    options = {
      preRules = mkOption {
        type = types.listOf jsonFormat.type;
        default = [];
      };

      rules = mkOption {
        type = notnft.types.ruleset;
        default = {};
      };

      postRules = mkOption {
        type = types.listOf jsonFormat.type;
        default = [];
      };

      flush = mkOption {
        type = types.bool;
        default = true;
      };

      # firewall = {
      #   interfaces = mkOption {
      #     default = {};
      #     type = types.attrsOf (types.submodule ({name, ...}: {
      #       options = {
      #         rules =
      #           lib.genAttrs
      #           ["input" "output" "forward"]
      #           (n:
      #             mkOption {
      #               type = with types; listOf unspecified;
      #               default = [];
      #               apply = foldl (x: y: x y) (with notnft.dsl; with payload; add chain);
      #             });
      #       };
      #     }));
      #   };
      # };
    };

    config.rules = with notnft.dsl;
    with payload;
      ruleset {
        filter =
          existing table {family = f: f.inet;}
          (lib.listToAttrs
            (lib.concatMap
              (interface: [
                {
                  name = "input-${interface.name}";
                  value = interface.value.rules.input;
                }
                {
                  name = "output-${interface.name}";
                  value = interface.value.rules.output;
                }
                {
                  name = "forward-${interface.name}";
                  value = interface.value.rules.forward;
                }
              ])
              (mapAttrsToList nameValuePair {})));
      };
  };
in {
  options.networking.notnft = {
    enable = mkEnableOption "notnft" // {
      default = true;
    };
    namespaces = mkOption {
      type = types.attrsOf (types.submodule notnftNamespace);
      default = {};
    };
  };

  config = mkMerge [
    {
      inputs = {
        notnft.url = "github:chayleaf/notnft/7d72e0b5c268921da51388fe1e4180637c3ae97d";
      };
    }
    (mkIf (config.networking.enable && cfg.enable) {
      _module.args = {notnft = inputs.notnft.lib.${pkgs.stdenv.system};};
      os = {
        boot.blacklistedKernelModules = ["ip_tables"];
        environment.systemPackages = [pkgs.nftables];

        systemd.services = flip mapAttrs' cfg.namespaces (
          n: v:
            nameValuePair "notnftables-${n}" {
              description = "notnftables firewall for the ${n} namespace";
              before = ["network-pre.target"];
              after = ["ifstate.service"];
              wants = ["network-pre.target"];
              wantedBy = ["multi-user.target"];
              reloadIfChanged = true;
              serviceConfig = let
                enterNamespace =
                  if n == "default"
                  then ""
                  else "${getExe' pkgs.iproute2 "ip"} netns exec ${n}";
                startScript = pkgs.writeShellScript "start-notnftables-${n}.sh" ''
                  ${enterNamespace} ${getExe pkgs.nftables} -j -f ${jsonFile n}
                '';
                # Checks would be nice, but they would have to be done in a VM as lkl seems to be broken with JSON rules
                # checkPhase = ''
                #   ${pkgs.stdenv.shellDryRun} "$target"
                #   export NIX_REDIRECTS="/etc/hosts:${config.environment.etc.hosts.source};/etc/protocols:${config.environment.etc.protocols.source};/etc/services:${config.environment.etc.services.source}"
                #   LD_PRELOAD="${pkgs.buildPackages.libredirect}/lib/libredirect.so ${pkgs.buildPackages.lklWithFirewall.lib}/lib/liblkl-hijack.so" \
                #   ${pkgs.buildPackages.nftables}/bin/nft --check --json --file ${jsonFile}
                # '';

                stopScript = pkgs.writeShellScript "stop-notnftables-${n}.sh" ''
                  ${optionalString cfg.namespaces.${n}.flush "${enterNamespace} ${getExe pkgs.nftables} flush ruleset"}
                '';
              in {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = startScript;
                ExecReload = startScript;
                ExecStop = stopScript;
              };
            }
        );
      };
    })
  ];
}

