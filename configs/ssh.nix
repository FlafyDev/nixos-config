{
  system = _: {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    programs.seahorse.enable = true;
  };

  home = _: {
    services.gnome-keyring = {
      enable = true;
      components = ["pkcs11" "secrets" "ssh"];
    };

    home.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    };
  };
}
