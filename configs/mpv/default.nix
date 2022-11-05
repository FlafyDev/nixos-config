{
  add = _: {
    overlays = _: [
      (final: prev: {
        svpflow =
          prev.callPackage
          ./svpflow.nix
          {};
        mpvScripts =
          prev.mpvScripts
          // {
            modern-x-compact = prev.callPackage ./scripts/modern-x-compact.nix {};
          };
      })
    ];

    # Extends the Home Manager Mpv modules to allow Mpv scripts to add fonts.
    homeModules = [./hm-mpv-fonts.nix];
  };

  home = {pkgs, ...}: {
    home.packages = with pkgs; [
      syncplay
      yt-dlp
    ];

    # home.file.".config/mpv/motioninterpolation.py".source = pkgs.substituteAll {
    #   src = ./motioninterpolation.py;
    #   mvtoolslib = "${pkgs.vapoursynth-mvtools}/lib/vapoursynth/";
    # };
    #
    # home.file.".config/mpv/svp.py".source = pkgs.substituteAll {
    #   src = ./svp.py;
    #   svpflow = "${pkgs.svpflow}/lib/";
    #   mvtoolslib = "${pkgs.vapoursynth-mvtools}/lib/vapoursynth/";
    # };

    programs.mpv = let
      # mpv-unwrapped = pkgs.mpv-unwrapped.override { vapoursynthSupport = true; };
      # mpv = pkgs.wrapMpv mpv-unwrapped { };
    in {
      enable = true;
      enableFonts = true;
      # package = mpv;
      config = {
        vo = "gpu";
        profile = "gpu-hq";
        # hwdec = "auto-safe";
        # gpu-context = "wayland";
        # force-window = true;
        ytdl-format = "bestvideo+bestaudio";
        volume-max = 200;
        fs = true;
        screen = 0;
        # save-position-on-quit = true;
        osc = false;
        # vf = "format=yuv420p,vapoursynth=~~/motioninterpolation.vpy:4:4";
        # vf = "vapoursynth=~~/svp.py:2:24";
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
        I = "vf toggle format=yuv420p,vapoursynth=~~/motioninterpolation.vpy:4:4";
      };
      scripts = with pkgs.mpvScripts; [
        modern-x-compact
        mpris
        autoload
      ];
    };
  };
}
