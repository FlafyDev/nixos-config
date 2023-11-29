_: {
  users.main = "server";

  printers.enable = true;

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
  games.services.minecraft.enable = true;

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
