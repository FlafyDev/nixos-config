{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.mpv;
in {
  options.programs.mpv = {
    enable = mkEnableOption "mpv";
  };

  config = mkIf cfg.enable {
    # Extends the Home Manager Mpv modules to allow Mpv scripts to add fonts.
    homeModules = [./hm-mpv-fonts.nix];

    nixpkgs.overlays = [
      (_final: prev: {
        mpvScripts =
          prev.mpvScripts
          // {
            modern-x-compact = prev.callPackage ./scripts/modern-x-compact.nix {};
          };
      })
    ];

    home.programs.mpv = {
      enable = true;
      enableFonts = true;
      # package = mpv;
      config = {
        vo = "gpu";
        profile = "gpu-hq";
        hwdec = "auto-safe";
        gpu-context = "wayland";
        # force-window = true;
        ytdl-format = "bestvideo+bestaudio";
        volume-max = 200;
        fs = true;
        screen = 0;
        # save-position-on-quit = true;
        osc = false;
      };
      bindings = {
        UP = "add volume 2";
        DOWN = "add volume -2";
        WHEEL_UP = "add volume 2";
        WHEEL_DOWN = "add volume -2";
        "ctrl+pgup" = "playlist-next";
        "ctrl+pgdwn" = "playlist-prev";
        RIGHT = "seek 5 exact";
        LEFT = "seek -5 exact";
      };
      scripts = with pkgs.mpvScripts; [
        modern-x-compact
        mpris
        autoload
      ];
    };
  };
}
