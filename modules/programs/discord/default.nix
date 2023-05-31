{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.discord;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.discord = {
    enable = mkEnableOption "discord";
    webcord.enable = mkEnableOption "webcord" // {default = true;};
  };

  config = mkIf (cfg.enable && cfg.webcord.enable) {
    os.nixpkgs.overlays = [
      (_final: prev: {
        webcord-vencord = prev.webcord-vencord.overrideAttrs (old: {
          patches =
            old.patches ++ [./webcord/unwritable-config.patch];
        });
      })
    ];

    os.environment.systemPackages = with pkgs; [webcord-vencord];
    hm.xdg.configFile."WebCord/Themes/amoled-cord".source = ./themes/amoled-cord.css;
    hm.xdg.configFile."WebCord/config.json".source = ./webcord/config.json;
  };
}
