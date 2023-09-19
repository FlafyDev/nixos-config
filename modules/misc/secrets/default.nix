{
  inputs,
  lib,
  config,
  osConfig,
  pkgs,
  ...
}:
with lib; let
  cfg = config.secrets;
  inherit (lib) mkOption types;
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

          serviceConfig.User = "flafy";
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
      mkIf
      cfg.enable {
        osModules = [inputs.agenix.nixosModules.default];

        os.age.secrets = {
          bitwarden = {
            file = ./secrets/bitwarden.age;
            mode = "400";
            owner = "flafy";
            group = "users";
          };
        };
        os.age.identityPaths = [
          "/home/flafy/.ssh/agenix"
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
