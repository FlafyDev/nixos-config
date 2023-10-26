{
  lib,
  elib,
  config,
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

    wallpaperTop = mkOption {
      type = types.raw;
      description = ''
        The top layer of the wallpaper.
        Usually used to simulate depth.
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
      description = ''
        The color to use on top of the blur.
      '';
    };

    popupBackgroundColor = mkOption {
      type = types.raw;
      description = ''
        The color to use on top of the blur.
      '';
    };

    borderColor.active = mkOption {
      type = types.raw;
      description = ''
        The color to for active window border.
      '';
    };

    borderColor.inactive = mkOption {
      type = types.raw;
      description = ''
        The color to for inactive window border.
      '';
    };
  };

  config = {
    elib.enable = true;
    _module.args.theme = config.theme;
  };
}
