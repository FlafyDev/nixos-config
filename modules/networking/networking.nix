{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption;
  cfg = config.networking;
in {
  options.networking = {
    enable = mkEnableOption "networking";
    domains = mkOption {
      type = with lib.types; attrsOf str;
      default = {
        personal = "flafy.dev";
      };
      description = "Domains";
    };
  };

  config = mkIf cfg.enable {
    utils.extraUtils = {
      inherit (cfg) domains;
    };

    os.boot.kernel.sysctl = {
      "net.ipv4.conf.all.route_localnet" = 1;
      "net.ipv4.ip_forward" = 1;
    };
  };
}
