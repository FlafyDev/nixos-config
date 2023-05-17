{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.ssh;
in {
  options.programs.ssh = {
    enable = mkEnableOption "ssh";

    # TODO
    server = mkOption {
      type = listOf bool;
      default = false;
      description = "Whether to start an SSH server.";
    };
  };

  config = mkIf cfg.enable {
    sys.services.gnome.gnome-keyring.enable = true;
    home.services.gnome-keyring = {
      enable = true;
      components = ["pkcs11" "secrets" "ssh"];
    };

    sys = {
      security.pam.services.login.enableGnomeKeyring = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      programs.seahorse.enable = true;
    };

    home = {
      home.sessionVariables = {
        SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      };
    };
  };
}
