{ config, lib, pkgs, ... }:
  with lib;
  
  let
    cfg = config.programs.betterdiscord;
    discordPackage = cfg.package;
    configDir = xdg;
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
    };

    config = mkIf cfg.enable {
      home.packages = [ discordPackage ];
      xdg.configFile = let
        asarLocation = "BetterDiscord/data/betterdiscord.asar";
        d_core = "discord/${discordPackage.version}/modules/discord_desktop_core";
        configDir = "${config.home.homeDirectory}/.config";
      in {
        ${asarLocation}.source = "${pkgs.betterdiscord-asar}/betterdiscord.asar";
        "${d_core}/index.js".text = ''
          require("${configDir}/${asarLocation}");module.exports=require("${configDir}/${d_core}/core.asar");
        '';
      };
    };
  }