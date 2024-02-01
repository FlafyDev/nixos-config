{
  inputs,
  pkgs,
  osConfig,
  config,
  theme,
  lib,
  ...
}: {
  options.programs.anyrun.enable = lib.mkEnableOption "anyrun";

  config = lib.mkMerge [
    {
      inputs = {
        anyrun = {
          url = "github:kirottu/anyrun";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        anyrun-nixos-options = {
          url = "github:n3oney/anyrun-nixos-options/v1.0.1";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    }
    (lib.mkIf config.programs.anyrun.enable {
      os.nix.settings = {
        substituters = ["https://anyrun.cachix.org"];

        trusted-public-keys = [
          "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        ];
      };

      hmModules = [inputs.anyrun.homeManagerModules.default];

      hm.programs.anyrun = {
        enable = true;

        config = {
          y.fraction = 0.2;
          width = { fraction = 0.3; };
          closeOnClick = true;
          hidePluginInfo = true;
          showResultsImmediately = true;
          maxEntries = 10;
          plugins = with inputs.anyrun.packages.${pkgs.system}; [
            applications
            rink
            inputs.anyrun-nixos-options.packages.${pkgs.system}.default
            translate
            # symbols # prefix not working
          ];
        };
        extraConfigFiles = {
          "nixos-options.ron".text = ''
            Config(
              options_paths: ${builtins.toJSON ["${osConfig.system.build.manual.optionsJSON}/share/doc/nixos/options.json"]},
              prefix: ";nix",
            )
          '';

          "translate.ron".text = ''
            Config(
              prefix: ";",
              language_delimiter: ">",
              max_entries: 1,
            )
          '';

          "symbols.ron".text = ''
            Config(
              prefix: ";sym",
              max_entries: 3,
            )
          '';
        };

        extraCss = ''
          window {
            background: transparent;
          }

          #match,
          #entry,
          #plugin,
          #main {
            background: transparent;
            font-size: 1.1rem;
          }

          #match.activatable {
            padding: 12px 14px;
            border-radius: 12px;

            color: white;
            margin-top: 4px;
            border: 2px solid transparent;
            transition: all 0.3s ease;
          }

          #match.activatable:not(:first-child) {
            border-top-left-radius: 0;
            border-top-right-radius: 0;
            border-top: 2px solid rgba(255, 255, 255, 0.1);
          }

          #match.activatable #match-title {
            font-size: 1.3rem;
          }

          #match.activatable:hover {
            border: 2px solid rgba(255, 255, 255, 0.4);
          }

          #match-title, #match-desc {
            color: inherit;
          }

          #match.activatable:hover, #match.activatable:selected {
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
          }

          #match.activatable:selected + #match.activatable, #match.activatable:hover + #match.activatable {
            border-top: 2px solid transparent;
          }

          #match.activatable:selected, #match.activatable:hover:selected {
            background: rgba(255,255,255,0.1);
          }

          #match, #plugin {
            box-shadow: none;
          }

          #entry {
            color: white;
            box-shadow: none;
            border-radius: 12px;
          }

          box#main {
            /* background: rgba(36, 39, 58, 0.7); */
            background: rgba(${toString theme.popupBackgroundColor.r}, ${toString theme.popupBackgroundColor.g}, ${toString theme.popupBackgroundColor.b}, ${toString theme.popupBackgroundColor.toNormA});
            border-radius: 16px;
            padding: 8px;
            box-shadow: 0px 2px 33px -5px rgba(0, 0, 0, 0.4);
          }

          row:first-child {
            margin-top: 6px;
          }
        '';
      };
    })
  ];
}
