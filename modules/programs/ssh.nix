{
  lib,
  config,
  ...
}: let
  cfg = config.programs.ssh;
  inherit (lib) mkEnableOption mkOption types mkIf;
in {
  options.programs.ssh = {
    enable = mkEnableOption "ssh";

    # TODO
    server = mkOption {
      type = with types; listOf bool;
      default = false;
      description = "Whether to start an SSH server.";
    };
  };

  config = mkIf cfg.enable {
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
  };
}
