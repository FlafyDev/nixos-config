{
  lib,
  config,
  ...
}:
with lib; {
  options.theme = {
    # enable = mkEnableOption "theme";
    wallpaper = mkOption {
      type = types.anything;
      default = null;
      description = ''
        The wallpaper to use.
      '';
    };
  };
}
