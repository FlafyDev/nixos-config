{
  lib,
  config,
  pkgs,
  inputs,
  theme,
  ...
}: let
  cfg = config.programs.gui-utils;
  inherit (lib) mkEnableOption mkIf mkMerge;
in {
  options.programs.gui-utils = {
    enable = mkEnableOption "gui-utils";
  };

  config = mkMerge [
    {
      inputs = {
        guifetch = {
          url = "github:flafydev/guifetch";
          # inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    }
    (mkIf cfg.enable {
      unfree.allowed = ["unityhub"];
      hmModules = [inputs.guifetch.homeManagerModules.default];
      hm.programs.guifetch = {
        enable = true;
        config = {
          backgroundColor = "${theme.backgroundColor.toHexARGB}";
        };
      };
      os.environment.systemPackages = with pkgs; [
        chromium
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
    })
  ];
}
