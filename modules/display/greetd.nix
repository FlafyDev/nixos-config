{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: let
  cfg = config.display.greetd;
  inherit (lib) mkEnableOption mkIf;
in {
  options.display.greetd = {
    enable = mkEnableOption "greetd";
  };

  config = mkIf cfg.enable {
    os.services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd \"offload-igpu hyprland\"";
          user = hmConfig.home.username;
        };
      };
    };
  };
}
