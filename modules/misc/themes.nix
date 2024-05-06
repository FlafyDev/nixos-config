{
  lib,
  utils,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types mkIf mkMerge;
  inherit (utils) mkColor;
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
      wallpaper = wallpapers.windows11-flower-monochrome.default;
      wallpaperTop = wallpapers.windows11-flower-monochrome.default;
      wallpaperBlurred = wallpapers.windows11-flower-monochrome.default;
      # backgroundColor = mkColor 0 0 0 153;
      backgroundColor = mkColor 0 0 0 51;
      popupBackgroundColor = mkColor 0 0 0 50;
      borderColor.active = mkColor 255 255 255 255;
      borderColor.inactive = mkColor 68 68 68 255;
    })
    (mkIf (cfg.themeName == "amoled-blue") {
      wallpaper = wallpapers.windows11-flower.default;
      wallpaperTop = wallpapers.windows11-flower.top;
      wallpaperBlurred = wallpapers.windows11-flower.blurred;
      # backgroundColor = mkColor 0 0 0 153;
      backgroundColor = mkColor 0 0 0 153;
      popupBackgroundColor = mkColor 0 0 0 50;
      borderColor.active = mkColor 135 140 198 255;
      borderColor.inactive = mkColor 39 44 86 255;
    })
  ];
}
