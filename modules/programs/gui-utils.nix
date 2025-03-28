{
  lib,
  config,
  pkgs,
  inputs,
  utils,
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
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    }
    (mkIf cfg.enable {
      unfree.allowed = ["unityhub"];
      hmModules = [inputs.guifetch.homeManagerModules.default];
      hm.xdg.configFile."flarrent/config.json".text = builtins.toJSON {
        color = theme.borderColor.active.toHexARGB;
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
        (utils.flPkgs inputs.flarrent)
        zed-editor
        kdePackages.kdenlive
        chromium
        eog # eye of gnome - image viewer
        mate.engrampa
        nautilus # file manager
        scrcpy
        simple-scan # scanner
        evince # document viewer
        gnome-system-monitor
        gnome-font-viewer
        gimp
        gparted
        pavucontrol

        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-vaapi
        libva

        libreoffice

        (pkgs.wrapOBS {
          plugins = with pkgs.obs-studio-plugins; [
            obs-vaapi
            obs-gstreamer
          ];
        })

        lxde.lxrandr
        syncplay
        prismlauncher
        thunderbird
        icu
        glib
      ];
    })
  ];
}
