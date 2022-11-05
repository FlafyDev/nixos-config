({ config, lib, pkgs, ... }:
  with lib;
  
  let
    cfg = config.programs.mpv;
  in {
    options = {
      programs.mpv = {
        enableFonts = lib.mkEnableOption "mpv-fonts";
      };
    };

    config = mkIf (cfg.enable && cfg.enableFonts) {
      xdg.configFile = mkMerge 
        (lists.flatten 
          (map (script: 
            (if script ? "fonts" then
                (map (font: {
                  "mpv/fonts/${font}".source = "${script}/share/mpv/fonts/${font}";
                }) script.fonts)
              else []
            ))
            cfg.scripts
          )
        );
    };
  }
)
