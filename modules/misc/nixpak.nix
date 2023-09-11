{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.nixpak;
  inherit (lib) mkEnableOption mkIf mkMerge;
in {
  options.nixpak = {
    enable = mkEnableOption "nixpak";
  };

  config = mkMerge [
    {
      inputs = {
        nixpak = {
          url = "github:nixpak/nixpak";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    }
    (
      mkIf cfg.enable {
        os.nixpkgs.overlays = [
          (_final: _prev: {
            mkNixPak = inputs.nixpak.lib.nixpak {
              inherit (_prev) lib;
              pkgs = _prev;
            };
          })
        ];
      }
    )
  ];
}
