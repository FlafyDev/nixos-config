{
  inputs,
  lib,
  config,
  osConfig,
  hmConfig,
  pkgs,
  utils,
  ...
}:
with lib; let
  cfg = config.secrets;
  secretsDir = ../../../secrets;
  inherit (lib) mkOption types foldl';
  inherit (utils) concatPaths;
  inherit (builtins) readDir;
in {
  options.secrets = {
    enable = mkEnableOption "secrets";
    autoBitwardenSession = {
      enable = mkEnableOption "autoBitwardenSession";
      sessionFile = mkOption {
        type = types.str;
        default = "~/.bw_session";
        description = "Path to the file where the Bitwarden session will be stored";
      };
    };
  };

  config = mkMerge [
    {
      inputs.agenix = {
        url = "github:ryantm/agenix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    }
    (
      mkIf (cfg.autoBitwardenSession.enable && cfg.enable) {
        os.systemd.services.bitwarden-session = {
          wantedBy = ["default.target"];

          serviceConfig.User = config.users.main;
          serviceConfig.ExecStart = let
            bw = "${pkgs.bitwarden-cli}/bin/bw";
            script = pkgs.writeShellScript "bw-session" ''
              source ${osConfig.age.secrets.bitwarden.path}

              ${bw} login --apikey --nointeraction
              export BW_SESSION="$(${bw} unlock --raw --passwordenv BW_PASSWORD --nointeraction)"
              echo "$BW_SESSION" > ${cfg.autoBitwardenSession.sessionFile}
            '';
          in
            script;
        };
      }
    )
    (
      mkIf cfg.enable {
        osModules = [inputs.agenix.nixosModules.default];

        _module.args.secrets = lib.mapAttrs (_name: value: value.path) osConfig.age.secrets;
        _module.args.ssh = foldl' (
          acc: host:
            acc
            // {
              ${host} = foldl' (acc: key:
                acc
                // {
                  ${key} = {
                    private = osConfig.age.secrets."${host}-${key}".path;
                    public = concatPaths [secretsDir "ssh-keys" host key "public"];
                  };
                }) {} (attrNames (readDir (concatPaths [secretsDir "ssh-keys" host])));
            }
        ) {} (attrNames (readDir (concatPaths [secretsDir "ssh-keys"])));

        hm.home.file = let
          inherit (config.users) host;
        in
          foldl' (acc: key:
            acc
            // {
              ".ssh/${key}".source = hmConfig.lib.file.mkOutOfStoreSymlink osConfig.age.secrets."${host}-${key}".path;
            }) {} (
            if (pathExists (concatPaths [secretsDir "ssh-keys" host]))
            then (attrNames (readDir (concatPaths [secretsDir "ssh-keys" host])))
            else []
          );

        os.age.secrets = let
          sshKeys = foldl' (
            acc: host:
              acc
              // (foldl' (acc: key:
                acc
                // {
                  "${host}-${key}" = {
                    file = concatPaths [secretsDir "ssh-keys" host key "private.age"];
                    mode = "400";
                    owner = config.users.main;
                    group = "users";
                  };
                }) {} (attrNames (readDir (concatPaths [secretsDir "ssh-keys" host]))))
          ) {} (attrNames (readDir (concatPaths [secretsDir "ssh-keys"])));
        in
          sshKeys
          // {
            bitwarden = {
              file = concatPaths [secretsDir "other" "bitwarden.age"];
              mode = "400";
              owner = config.users.main;
              group = "users";
            };
            porkbun = {
              file = concatPaths [secretsDir "other" "porkbun.age"];
              mode = "440";
              owner = "acme";
              group = "acme";
            };
            "mail.flafy_dev.flafy" = {
              file = concatPaths [secretsDir "other" "mail" "flafy_dev" "flafy.age"];
              mode = "440";
              owner = "virtualMail";
              group = "virtualMail";
            };
            matrix-sliding-sync = {
              file = concatPaths [secretsDir "other" "matrix_sliding_sync_secret.age"];
              mode = "440";
              owner = "matrix-sliding-sync";
              group = "matrix-sliding-sync";
            };
          };

        os.age.identityPaths = [
          "/home/${config.users.main}/.ssh/agenix"
        ];

        os.environment.systemPackages = [
          (utils.flPkgs inputs.agenix)
        ];

        # hm.systemd.user.services.bitwarden-session = {
        #   Unit = {
        #     Description = "Generate a new session for Bitwarden CLI";
        #     After = ["run-agenix.d.mount"];
        #     # PartOf = ["graphical-session.target"];
        #   };
        #
        #   Service = {
        #     # WantedBy = ["default.target"];
        #     # Type = "oneshot";
        #     # RemainAfterExit = true;
        #     ExecStart = ;
        #   };
        #
        #   # Install = {WantedBy = ["graphical-session.target"];};
        # };

        # os.environment.sessionVariables.BW_SESSION =;
      }
    )
  ];
}
