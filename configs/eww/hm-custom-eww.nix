{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.customEww;
  package = pkgs.writeShellScriptBin "eww" ''
    PATH="$PATH:${lib.makeBinPath cfg.dependencies}"
    exec ${cfg.package}/bin/eww "$@"
  '';
in
{
  options.programs.customEww = {
    enable = mkEnableOption "customEww";

    package = mkOption {
      type = types.package;
      default = pkgs.eww;
      defaultText = literalExpression "pkgs.eww";
      example = literalExpression "pkgs.eww";
      description = ''
        The eww package to install.
      '';
    };

    scss = mkOption {
      type = types.path;
      description = ''
        The scss file that gets symlinked as
        <filename>$XDG_CONFIG_HOME/eww/eww.scss</filename>.
      '';
    };

    yuck = mkOption {
      type = types.path;
      description = ''
        The yuck file that gets symlinked as
        <filename>$XDG_CONFIG_HOME/eww/eww.yuck</filename>.
      '';
    };

    dependencies = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = ''
        The dependencies the yuck files will use.
      '';
    };

    assets = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = literalExpression "./assets";
      description = ''
        The assets directory that gets symlinked as
        <filename>$XDG_CONFIG_HOME/eww/assets</filename>.
      '';
    };
  };

  config = mkIf cfg.enable {
    # systemd.user.services.eww = {
    #   Unit = {
    #     Description = "Eww Daemon";
    #     # not yet implemented
    #     # PartOf = ["tray.target"];
    #     PartOf = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     # Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
    #     ExecStart = "${package}/bin/eww daemon --no-daemonize";
    #     Restart = "on-failure";
    #   };
    #   Install.WantedBy = [ "graphical-session.target" ];
    # };
    home.packages = [ package ];
    xdg.configFile = {
      "eww/eww.yuck".source = cfg.yuck;
      "eww/eww.scss".source = cfg.scss;
      "eww/assets".source = cfg.assets;
    };
  };
}
