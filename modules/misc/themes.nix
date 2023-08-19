{
  lib,
  elib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf mkMerge;
  inherit (elib) mkColor;
  inherit (pkgs.assets) wallpapers;
  cfg = config.themes;
in {
  options.themes = {
    themeName = mkOption {
      type = with types; nullOr str;
      default = null;
      description = ''
        Theme to use
      '';
    };
  };
  config.theme = mkMerge [
    (mkIf (cfg.themeName == "amoled") {
      wallpaper = wallpapers.windows11-flower.default;
      wallpaperTop = wallpapers.windows11-flower.top;
      wallpaperBlurred = wallpapers.windows11-flower.blurred;
      backgroundColor = mkColor 0 0 0 153;
      borderColor.active = mkColor 117 117 133 85;
      borderColor.inactive = mkColor 117 117 133 85;
    })
  ];
}
