{pkgs, ...}: {
  users.main = "flafy";

  os.services = {
    xserver = {
      enable = true;
      dpi = 96;
      videoDrivers = ["amdgpu"];
      autorun = false;
    };
  };
  os.services.xserver.desktopManager.plasma5.enable = true;
  os.programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

  android.enable = true;
  display.greetd.enable = true;
  display.hyprland.enable = true;
  fonts.enable = true;
  printers.enable = true;

  assets.enable = true;

  themes.themeName = "amoled";

  localhosts.enable = true;
  vm.enable = true;
  games.enable = true;

  programs.firefox.enable = true;
  gtk.enable = true;
  programs.gnome.enable = false;
  programs.mpv.enable = true;
  programs.vscode.enable = true;
  programs.neovim.enable = true;
  programs.cli-utils.enable = true;
  programs.transmission.enable = true;
  programs.direnv.enable = true;
  programs.fish.enable = true;
  programs.foot.enable = true;
  programs.git.enable = true;
  programs.nix.enable = true;
  programs.ssh.enable = true;
  programs.discord.enable = true;
  programs.gui-utils.enable = true;
}
