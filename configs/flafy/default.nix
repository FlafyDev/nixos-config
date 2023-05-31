{pkgs, ...}: {
  users.main = "flafy";

  display.greetd.enable = true;
  display.hyprland.enable = true;
  fonts.enable = true;
  printers.enable = true;

  assets.enable = true;

  themes.themeName = "amoled";

  programs.firefox.enable = true;
  gtk.enable = true;
  programs.mpv.enable = true;
  programs.neovim.enable = true;
  programs.cli-utils.enable = true;
  programs.deluge.enable = true;
  programs.direnv.enable = true;
  programs.fish.enable = true;
  programs.foot.enable = true;
  programs.git.enable = true;
  programs.nix.enable = true;
  programs.ssh.enable = true;
  programs.discord.enable = true;
  programs.gui-utils.enable = true;
}
