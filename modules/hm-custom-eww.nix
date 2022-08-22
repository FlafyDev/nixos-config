{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.customEww;
in {
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
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."eww/eww.yuck".source = cfg.yuck;
    xdg.configFile."eww/eww.scss".source = cfg.scss;
  };
}
