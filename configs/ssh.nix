{username ? ""}: let
  sshPath = "/secrets/ssh/${username}";
in {
  system = _: {
    # programs.ssh = {
    #   startAgent = true;

    #   # knownHosts = {
    #   #   "github.com" = {
    #   #     publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODYVo8TbkZ5N5PKjq1DUCeVB59Ac23eahyKvq14uVo0 flafyarazi@gmail.com";
    #   #   };
    #   # };
    # };
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    programs.seahorse.enable = true;

    systemd.services.gnome-keyring-daemon-ssh-agent = {
      enable = true;
      description = "Custom service to start gnome-keyring-daemon ssh agent";
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        ExecStart = "/run/wrappers/bin/gnome-keyring-daemon --start --components=ssh";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  home = {pkgs, ...}: {
    # programs.keychain = {
    #   enable = true;
    #   enableZshIntegration = false;
    # };

    services.gnome-keyring = {
      enable = true;
      components = ["pkcs11" "secrets" "ssh"];
    };

    home.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    };


    # programs.zsh = {
    #   initExtra = ''
    #     eval "$(${pkgs.keychain}/bin/keychain --eval --agents ssh ~/.ssh/id_*)"
    #   '';
    #   # initExtra = builtins.concatStringsSep "\n" (map (key: ''
    #   #     eval "$(SHELL=zsh ${pkgs.keychain}/bin/keychain --eval --agents ssh ${sshPath}/${key})"
    #   #   '')
    #   #   [
    #   #     "id_github"
    #   #   ]);
    # };

    # programs.ssh = {
    #   enable = true;

    #   # userKnownHostsFile = "${sshPath}/known_hosts";

    #   # matchBlocks = {
    #   #   "github.com" = {
    #   #     hostname = "github.com";
    #   #     user = "git";
    #   #     identityFile = ["${sshPath}/id_github"];
    #   #   };
    #   # };
    # };
  };
}
