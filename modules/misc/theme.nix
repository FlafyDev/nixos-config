{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.theme = {
    wallpaper = mkOption {
      type = types.anything;
      default = null;
      description = ''
        The wallpaper to use.
      '';
    };
  };
}
