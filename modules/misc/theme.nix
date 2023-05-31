{
  lib,
  elib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.theme = {
    wallpaper = mkOption {
      type = types.raw;
      description = ''
        The wallpaper to use.
      '';
    };

    wallpaperBlurred = mkOption {
      type = types.raw;
      description = ''
        The wallpaper to use as blur.
      '';
    };

    backgroundColor = mkOption {
      type = types.raw;
      default = elib.mkColor 0 0 0 100;
      description = ''
        The color to use on top of the blur.
      '';
    };
  };

  config.elib.enable = true;
}
