{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.display.greetd;
in {
  options.display.greetd = {
    enable = mkEnableOption "greetd";
  };

  config = mkIf cfg.enable {
    sys.services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd hyprland";
          user = config.home.home.username;
        };
      };
    };
  };
}
