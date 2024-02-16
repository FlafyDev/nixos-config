{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.sunshine;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options.programs.sunshine = {
    enable = mkEnableOption "sunshine";
    package = mkOption {
      type = with types; package;
      default = pkgs.sunshine;
      description = ''
        Sunshine package.
      '';
    };
    hyprlandIntegration.enable = mkEnableOption "hyprlandIntegration";
  };

  config = mkIf (cfg.enable && cfg.hyprlandIntegration.enable) {
    hm.wayland.windowManager.hyprland.settings.exec-once = [
      (pkgs.writeShellScript "sunshine-launcher" ''
        while true; do
          "${cfg.package}/bin/sunshine" || true
          sleep 1
        done
      '')
    ];
  };
}
