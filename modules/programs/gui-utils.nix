{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.gui-utils;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.gui-utils = {
    enable = mkEnableOption "gui-utils";
  };

  config = mkIf cfg.enable {
    unfree.allowed = ["unityhub"];
    os.environment.systemPackages = with pkgs; [
      gnome.eog
      mate.engrampa
      gnome.nautilus
      scrcpy
      gnome.simple-scan
      gnome.evince
      gnome.gnome-system-monitor
      gnome.gnome-font-viewer
      gimp
      gparted
      pavucontrol
      obs-studio
      lxde.lxrandr
      syncplay
      prismlauncher
      unityhub
      icu
      glib
    ];
  };
}
