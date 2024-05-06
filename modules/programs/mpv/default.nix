{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.mpv;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.mpv = {
    enable = mkEnableOption "mpv";
  };

  config = mkIf cfg.enable {
    # Extends the Home Manager Mpv modules to allow Mpv scripts to add fonts.
    hmModules = [./hm-mpv-fonts.nix];

    os.nixpkgs.overlays = [
      (_final: prev: {
        mpvScripts =
          prev.mpvScripts
          // {
            modern-x-compact = prev.callPackage ./scripts/modern-x-compact.nix {};
          };
      })
    ];

    hm.programs.mpv = {
      enable = true;
      enableFonts = true;
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
        (let
          script = pkgs.writeText "mpv-script" ''
            function show_meta()
                local ass_start = mp.get_property_osd("osd-ass-cc/0")
                local ass_stop = mp.get_property_osd("osd-ass-cc/1" .. "expand-properties/0")
                local ass_text = "{\\b1}''${filename}{\\b0}{\\fscx70\\fscy70}  [''${height}p ''${video-format}]\n" ..
                                 "''${?metadata/by-key/title:\nTITLE: ''${metadata/by-key/title}}" ..
                                 "''${?metadata/by-key/artist:\nARTIST: ''${metadata/by-key/artist}}" ..
                                 "''${?metadata/by-key/album:\nALBUM: ''${metadata/by-key/album}}" ..
                                 "''${?metadata/by-key/date:\nDATE: ''${metadata/by-key/date}}"

                mp.commandv("expand-properties", "show-text", ass_start .. ass_text .. ass_stop)
            end

            mp.add_key_binding('n', 'show-meta', show_meta)
            mp.register_event('file-loaded', show_meta)
          '';
        in
          pkgs.runCommand "mp3-metadata" {
            passthru.scriptName = "script.lua";
          } ''
            mkdir -p "$out/share/mpv/scripts/"
            cp ${script} "$out/share/mpv/scripts/script.lua"
          '')
      ];
    };
  };
}
