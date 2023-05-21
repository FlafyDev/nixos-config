{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./modules/misc/users.nix
  ];

  users.main = "falfy";
  sys.boot.kernelPackages = pkgs.linuxPackages_6_1;
  sys.hardware.nvidia.package = (builtins.trace config.sys.boot.kernelPackages config.sys.boot.kernelPackages).nvidiaPackages.latest;
  sys.system.stateVersion = "23.05";
  home.home.stateVersion = "23.05";
  # home.home.username = "a";
  # home.home.stateVersion = "23.05";
  # sys.users.users.a.isNormalUser = true;
  # sys.users.users.a.group = "a";

  # sysTopLevelModules = [
  #   ./hardware-configuration.nix
  # ];

  # imports = [
  #   ./modules
  # ];

  # imports = [
  #   ./modules/packages.nix
  #   ./modules/wayland/hyprland.nix
  #   ./modules/programs/nix.nix
  #   ./modules/programs/git.nix
  # ];

  # display.greetd.enable = false;
  # display.hyprland.enable = true;
  # fonts.enable = true;
  # printers.enable = true;
  # theme.wallpaper = "/home/a/Pictures/wallpaper.png";
  # programs.firefox.enable = true;
  # programs.mpv.enable = true;
  # programs.neovim.enable = true;
  # programs.cli-utils.enable = true;
  # programs.deluge.enable = true;
  # programs.direnv.enable = true;
  # programs.fish.enable = true;
  # programs.foot.enable = true;
  # programs.git.enable = true;
  # programs.nix.enable = true;
  # programs.ssh.enable = true;
}
