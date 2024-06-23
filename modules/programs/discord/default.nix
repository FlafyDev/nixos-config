{
  pkgs,
  lib,
  config,
  theme,
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
    os.environment.systemPackages = let
      webcord-vencord = pkgs.webcord-vencord.override {
        # Patch webcord
        # webcord = (pkgs.callPackage ./webcord/screenshare-audio.nix {}).overrideAttrs (old: {
        #   patches = (old.patches or []) ++ [./webcord/unwritable-config.patch];
        # });
        webcord = pkgs.webcord.overrideAttrs (old: rec {
          patches = (old.patches or []) ++ [./webcord/unwritable-config.patch];
        });

        # Patch vencord
        vencord-web-extension = pkgs.vencord-web-extension.overrideAttrs (old: {
          # patches =
          #   (old.patches or [])
          #   ++ [
          #     (pkgs.runCommand "vencord-settings-patch" {
          #         nativeBuildInputs = with pkgs; [jq];
          #       } ''
          #         export settings=$(jq -c '.settings' < ${./vencord/exported-settings.json})
          #         substituteAll ${./vencord/declarative-settings.patch} $out
          #       '')
          #   ];
        });
      };
    in [
      webcord-vencord
    ];

    hm.xdg.configFile."WebCord/Themes/amoled-cord".source = pkgs.substituteAll {
      src = ./themes/amoled-cord.css;
      backgroundColor = "#${theme.backgroundColor.toHexRGBA}";
    };
    hm.xdg.configFile."WebCord/config.json".source = ./webcord/config.json;
  };
}
