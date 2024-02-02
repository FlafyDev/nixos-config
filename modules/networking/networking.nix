{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.networking;
in {
  options.networking = {
    enable = mkEnableOption "networking";
  };

  config = mkIf cfg.enable {
    localhosts.enable = true;
  };
}
