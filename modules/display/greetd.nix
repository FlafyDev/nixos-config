{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: let
  cfg = config.display.greetd;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options.display.greetd = {
    enable = mkEnableOption "greetd";
    command = mkOption {
      type = types.str;
      description = "Command to run after unlocking";
    };
  };

  config = mkIf cfg.enable {
    os.services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd \"${cfg.command}\"";
          user = hmConfig.home.username;
        };
      };
    };
  };
}
