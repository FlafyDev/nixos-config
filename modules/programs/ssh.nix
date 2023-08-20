{
  lib,
  config,
  ...
}: let
  cfg = config.programs.ssh;
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge;
in {
  options.programs.ssh = {
    enable = mkEnableOption "ssh";

    server = mkOption {
      type = with types; listOf bool;
      default = false;
      description = "Whether to start an SSH server.";
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.server) {
      services.openssh = {
        enable = true;
        # require public key authentication for better security
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
        #settings.PermitRootLogin = "yes";
      };
    })
    (mkIf cfg.enable {
      os.services.gnome.gnome-keyring.enable = true;
      hm.services.gnome-keyring = {
        enable = true;
        components = ["pkcs11" "secrets" "ssh"];
      };

      os = {
        security.pam.services.login.enableGnomeKeyring = true;
        security.pam.services.greetd.enableGnomeKeyring = true;
        programs.seahorse.enable = true;
      };

      hm.home.sessionVariables = {
        SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      };
    })
  ];
}
