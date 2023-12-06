{pkgs, ...}: {
  users.main = "server";

  printers.enable = true;
  
  os.services.openvscode-server = {
    enable = true;
    user = "server";
    withoutConnectionToken = true;
    package = pkgs.openvscode-server.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        ./temppatch.patch
      ];
    });
    host = "0.0.0.0";
    port = 58846; 
  };
  os.nixpkgs.config.permittedInsecurePackages = [
                "nodejs-16.20.2"
              ];

  programs.neovim.enable = true;
  programs.cli-utils.enable = true;
  # programs.transmission.enable = true;
  programs.direnv.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;
  programs.nix.enable = true;
  programs.ssh.enable = true;
  programs.ssh.server = true;
  users.groups = [ "sftpuser" ];
  games.services.minecraft.enable = false;

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
