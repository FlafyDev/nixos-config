{
  lib,
  pkgs,
  config,
  ...
}: {
  sysTopLevelModules = [
    ./hardware-configuration.nix
  ];
  sys = {
    users.users.root = {
      group = "root";
      password = "root";
      isSystemUser = true;
    };
    users.users.a = {
      group = "a";
      password = "a";
      isNormalUser = true;
    };
    users.mutableUsers = false;
  };
  home.home.username = "a";

  imports = [
    ./modules
  ];

  # imports = [
  #   ./modules/packages.nix
  #   ./modules/wayland/hyprland.nix
  #   ./modules/programs/nix.nix
  #   ./modules/programs/git.nix
  # ];

  display.greetd.enable = true;
  display.hyprland.enable = true;
  fonts.enable = false;
  printers.enable = true;
  theme.wallpaper = "/home/a/Pictures/wallpaper.png";
  programs.firefox.enable = true;
  programs.mpv.enable = true;
  programs.neovim.enable = true;
  programs.cli-utils.enable = false;
  programs.deluge.enable = true;
  programs.direnv.enable = true;
  programs.fish.enable = true;
  programs.foot.enable = true;
  programs.git.enable = true;
  programs.nix.enable = true;
  programs.ssh.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.home.stateVersion = "23.05";
  sys.system.stateVersion = "23.05";
}
