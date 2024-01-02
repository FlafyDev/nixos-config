{
  lib,
  config,
  pkgs,
  inputs,
  elib,
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
        flarrent = {
          url = "github:flafydev/flarrent";
          # inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    }
    (mkIf cfg.enable {
      unfree.allowed = ["unityhub"];
      hmModules = [inputs.guifetch.homeManagerModules.default];
      hm.xdg.configFile."flarrent/config.json".text = builtins.toJSON {
        color = "ff69bcff";
        backgroundColor = theme.backgroundColor.toHexARGB;
        connection = "transmission:http://localhost:9091/transmission/rpc";
        smoothScroll = false;
        animateOnlyOnFocus = false;
      };
      hm.programs.guifetch = {
        enable = true;
        config = {
          backgroundColor = "${theme.backgroundColor.toHexARGB}";
        };
      };
      os.environment.systemPackages = with pkgs; [
        (elib.flPkgs inputs.flarrent)
        kdenlive
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
        thunderbird
        icu
        glib
      ];
    })
  ];
}
