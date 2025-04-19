{
  inputs,
  lib,
  config,
  osConfig,
  secrets,
  pkgs,
  utils,
  ...
}:
with lib; let
  cfg = config.secrets;
  inherit (lib) mkOption types filterAttrs;
  inherit (utils) getAllSecrets transformToNestedPaths;
  inherit (builtins) mapAttrs;

  allSecrets = getAllSecrets {
    host = config.users.main;
  };
  hostSecrets = filterAttrs (_filePath: secret: elem config.users.host secret.hosts) allSecrets.secrets;
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
              source ${secrets.bitwarden.credentials}

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

        _module.args.secrets =
          transformToNestedPaths ((mapAttrs (filePath: _secret: osConfig.age.secrets.${filePath}.path) hostSecrets) // allSecrets.other);
        os = {
          age.secrets = let
            secrets = mapAttrs (_relFilePath: secret: {
              file = /. + secret.filePath;
              inherit (secret) mode owner group;
            }) hostSecrets;
          in
            secrets;

          age.identityPaths = [
            "/persist/home/${config.users.main}/.ssh/agenix"
            "/home/${config.users.main}/.ssh/agenix"
          ];

          environment.systemPackages = [
            (utils.flPkgs inputs.agenix)
          ];
        };
      }
    )
  ];
}
