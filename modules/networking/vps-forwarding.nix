{
  config,
  configs,
  lib,
  resolveHostname,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    mkIf
    foldlAttrs
    mapAttrs
    mapAttrs'
    concatStringsSep
    hasInfix
    mkMerge
    foldl'
    attrValues
    listToAttrs
    ;
  cfg = config.networking.vpsForwarding;

  portsToAllowVps = listToAttrs (map (
    protocol: {
      name = protocol;
      value = listToAttrs (
        map (port: {
          name = port;
          value = [cfg.settings.outgoingAddress]; ## TODO: Array?
        }) (
          foldl' (
            acc: config':
              acc
              ++ (config'.networking.vpsForwarding.${config.users.host}.${protocol}.ports or [])
          ) []
          (attrValues configs)
        )
      );
    }
  ) ["tcp" "udp"]);

  # networking.allowedPorts.tcp."58846" = [ "ope.wg_private.flafy.me" ];
  portsToAllowThis =
    mapAttrs (
      host: config': let
        address = "${config.users.host}.${configs.${host}.networking.vpsForwarding.${host}.settings.wireguardInterface}.flafy.me";
      in
        mapAttrs (_protocol: ports:
          listToAttrs (map (port: {
            name = port;
            value = [address];
          })
          ports))
        {inherit (config') udp tcp;}
    )
    cfg;

  # portsToAllowVps = listToAttrs (map (
  #   protocol: {
  #     name = protocol;
  #     value = listToAttrs (
  #       map (port: {
  #         name = port;
  #         value = ["${config.users.host}.${configs.${host}.networking.vpsForwarding.${host}.settings.wireguardInterface}.flafy.me"];
  #       }) (
  #         foldl' (
  #           acc: config':
  #             acc
  #             ++ (config'.networking.vpsForwarding.${config.users.host}.${protocol}.ports or [])
  #         ) []
  #         (attrValues configs)
  #       )
  #     );
  #   }
  # ) ["tcp" "udp"]);

  rules =
    (mapAttrs (host: config': let
      address = "${config.users.host}.${configs.${host}.networking.vpsForwarding.${host}.settings.wireguardInterface}.flafy.me";
    in
      concatStringsSep "\n" (foldlAttrs (acc: protocol: ports:
        acc
        ++ (
          map (port: let
            # Should this even be allowed?
            port' =
              if hasInfix "," port
              then "{${port}}"
              else port;
          in "${protocol} dport ${port'} dnat to ${resolveHostname address}:${port'}")
          ports
        )) []
      {inherit (config') tcp udp;}))
    cfg)
    .${config.users.host}
    or "";
in {
  options.networking.vpsForwarding = mkOption {
    type = with types;
      attrsOf (submodule (
        _: {
          options = {
            tcp = mkOption {
              type = with types; listOf str;
              default = [];
              description = ''
                List of TCP ports to forward.
              '';
            };
            udp = mkOption {
              type = with types; listOf str;
              default = [];
              description = ''
                List of UDP ports to forward.
              '';
            };
            settings = mkOption {
              type = with types;
                submodule (
                  _: {
                    options.wireguardInterface = mkOption {
                      type = types.str;
                      description = ''
                        Wireguard interface to use for VPS forwarding.
                      '';
                    };
                    options.outgoingAddress = mkOption {
                      type = types.str;
                      default = "0.0.0.0";
                      description = ''
                        Outgoing address for VPS forwarding.
                      '';
                    };
                  }
                );
              default = {};
              description = ''
                Settings to set by vps host.
              '';
            };
          };
        }
      ));
    default = {};
    description = ''
      VPS forwarding settings.
    '';
  };

  config = mkIf config.networking.enable (mkMerge [
    {
      os.networking.nftables = {
        enable = true;
        tables = {
          tunnel = {
            name = "tunnel";
            family = "ip";
            enable = true;

            # tcp dport 23-65535 dnat to 10.10.10.10:23-65535
            content = ''
              chain prerouting {
                  type nat hook prerouting priority 0 ;


                  ${rules}



                  # tcp dport 80 dnat to 10.10.10.11:80
                  # tcp dport 443 dnat to 10.10.10.11:443
                  # udp dport 51821 dnat to 10.10.10.10:51821

                  # tcp dport 47984 dnat to 10.10.10.10:47984
                  # tcp dport 47989 dnat to 10.10.10.10:47989
                  # tcp dport 48010 dnat to 10.10.10.10:48010
                  #
                  # udp dport 47998-48000 dnat to 10.10.10.10:47998-48000
                  # udp dport 48002 dnat to 10.10.10.10:48002
                  # udp dport 48010 dnat to 10.10.10.10:48010
              }

              chain postrouting {
                  type nat hook postrouting priority 100 ;
                  masquerade
              }
            '';
          };
        };
      };
      networking.allowedPorts = mkMerge [
        # portsToAllowVps
        (builtins.trace portsToAllowThis.mane.tcp."80" portsToAllowThis)
      ];
    }
  ]);
}
