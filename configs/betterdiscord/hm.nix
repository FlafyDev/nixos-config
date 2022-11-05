{ config, lib, pkgs, ... }:
  with lib;
  
  let
    cfg = config.programs.betterdiscord;
    discordPackage = cfg.package;
    configDir = xdg;
    theme = pkgs.betterdiscordThemes.solana;
  in {
    options.programs.betterdiscord = {
      enable = mkEnableOption "betterdiscord";

      package = mkOption {
        type = types.package;
        default = pkgs.discord;
        example = literalExpression
          "pkgs.discord";
        description = ''
          Package providing discord.
        '';
      };

      themes = mkOption {
        type = with types; listOf package;
        default = [ ];
        example = literalExpression "[ pkgs.betterdiscordThemes.solana ]";
        description = ''
          List of themes to use with BetterDiscord.
        '';
      };

      plugins = mkOption {
        type = with types; listOf package;
        default = [ ];
        example = literalExpression "[ pkgs.betterdiscordPlugins.hide-disabled-emojis ]";
        description = ''
          List of plugin to use with BetterDiscord.
        '';
      };
    };

    config = mkIf cfg.enable {
      home.packages = [ discordPackage ];
      xdg.configFile = let
        asarLocation = "BetterDiscord/data/betterdiscord.asar";
        d_core = "discord/${discordPackage.version}/modules/discord_desktop_core";
        configDir = "${config.home.homeDirectory}/.config";
      in mkMerge [
        {
          # There is a "bug" in BetterDiscord where the settings files can't be readonly otherwise it crashes...
          # "BetterDiscord/data/stable/themes.json".text = builtins.toJSON (
          #   evalModules { modules = [{
          #     res = (mkMerge (map (theme: {
          #       "${theme.themeName}" = true;
          #     }) cfg.themes));
          #   } {
          #     options = { res = mkOption { type = types.anything; }; };
          #   }]; }
          # ).config.res;
          
          "${asarLocation}".source = "${pkgs.betterdiscord-asar}/betterdiscord.asar";
          "${d_core}/index.js".text = ''
            require("${configDir}/${asarLocation}");module.exports=require("${configDir}/${d_core}/core.asar");
          '';
        }
        (mkMerge (map (theme: {"BetterDiscord/themes/${theme.themeName}.theme.css".source = "${theme}/theme.css"; }) cfg.themes ))
        (mkMerge (map (plugin: {"BetterDiscord/plugins/${plugin.pluginName}.plugin.js".source = "${plugin}/plugin.js"; }) cfg.plugins ))
      ];
    };
  }
