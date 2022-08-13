{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.eww;
in {
  options.programs.eww = {
    enable = mkEnableOption "eww";

    package = mkOption {
      type = types.package;
      default = pkgs.eww;
      defaultText = literalExpression "pkgs.eww";
      example = literalExpression "pkgs.eww";
      description = ''
        The eww package to install.
      '';
    };

    configDir = mkOption {
      type = types.path;
      example = literalExpression "./eww-config-dir";
      description = ''
        The directory that gets symlinked to
        <filename>$XDG_CONFIG_HOME/eww</filename>.
      '';
    };

    scripts = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile.
    xdg.configFile = mkMerge [
      { "eww".source = cfg.configDir; }
      cfg.
    ];
  };
}

