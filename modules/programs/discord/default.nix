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
        webcord = (pkgs.callPackage ./webcord/screenshare-audio.nix {}).overrideAttrs (old: {
          patches = (old.patches or []) ++ [./webcord/unwritable-config.patch];
        });
        # webcord = pkgs.webcord.overrideAttrs (old: rec {
        #   patches = (old.patches or []) ++ [./webcord/unwritable-config.patch];
        # });

        # Patch vencord
        vencord-web-extension = let
          inherit
            (import (pkgs.fetchFromGitHub {
              owner = "nixos";
              repo = "nixpkgs";
              rev = "df44b52336f82def62d8f79710ccf70eb7fed7d5";
              hash = "sha256-ZH0Ey4bdIAJ0cZ2yjK+A+iZN1/YwT6W0MQ9b89Bm1pI=";
            }) {inherit (pkgs) system;})
            vencord-web-extension
            ;
        in
          vencord-web-extension.overrideAttrs (old: {
            patches =
              (old.patches or [])
              ++ [
                (pkgs.runCommand "vencord-settings-patch" {
                    nativeBuildInputs = with pkgs; [jq];
                  } ''
                    export settings=$(jq -c '.settings' < ${./vencord/exported-settings.json})
                    substituteAll ${./vencord/declarative-settings.patch} $out
                  '')
              ];
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
