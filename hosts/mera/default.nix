{
  pkgs,
  config,
  ssh,
  ...
}: {
  imports = [./hardware];

  users.main = "server";
  users.host = "mera";



  secrets.enable = true;
  printers.enable = true;
  os.networking.hostName = config.users.host;

  bitwarden.enable = true;

  os.services.openvscode-server = {
    enable = true;
    user = "server";
    withoutConnectionToken = true;
    package = pkgs.openvscode-server.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./temppatch.patch
        ];
    });
    # host = "0.0.0.0";
    # port = 58846;
  };
  os.nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];

  games.services.badTimeSimulator.enable = true;
  programs.neovim.enable = true;
  programs.cli-utils.enable = true;
  # programs.transmission.enable = true;
  programs.direnv.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;
  programs.nix.enable = true;
  programs.ssh = {
    enable = true;

    matchBlocks = {
      ope = {
        identitiesOnly = true;
        identityFile = ["~/.ssh/mera_to_ope"];
      };
    };

    server = {
      enable = true;

      users.${config.users.main}.keyFiles = [
        ssh.ope.ope_to_mera.public
      ];
    };
  };


  users.groups = ["sftpuser"];

  os.services.vsftpd = {
    enable = true;
    #   cannot chroot && write
    #    chrootlocalUser = true;
    writeEnable = true;
    localUsers = true;
    # userlist = ["martyn" "cam"];
    # userlistEnable = true;
    # anonymousUserNoPassword = true;
    # anonymousUser = true;
  };
}
