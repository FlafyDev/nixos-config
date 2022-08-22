{
  home = { pkgs, ... }:
  {
    programs.mpv = {
      enable = true;
      enableFonts = true;
      config = {
        vo = "gpu";
        profile = "gpu-hq";
        hwdec = "yes";
        gpu-context = "wayland";
        force-window = true;
        ytdl-format = "bestvideo+bestaudio";
        volume-max = 200;
        fs = true;
        screen = 0;
        save-position-on-quit = true;
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
