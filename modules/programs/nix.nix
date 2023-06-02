{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.nix;
  inherit (lib) mkEnableOption mkIf mkMerge mapAttrs;
in {
  options.programs.nix = {
    enable = mkEnableOption "nix";
    cm-patch = mkEnableOption "combined-manager-patch" // {default = true;};
  };

  config = mkMerge [
    {
      inputs.nix-super = {
        url = "github:privatevoid-net/nix-super";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    }
    (mkIf (cfg.enable && cfg.cm-patch) {
      os.nixpkgs.overlays = [
        (_final: prev: {
          nix-super = inputs.nix-super.packages.${prev.system}.default;
        })
      ];
    })
    (mkIf (cfg.enable && !cfg.cm-patch) {
      os.nixpkgs.overlays = [
        (_final: prev: {
          nix = prev.nix.overrideAttrs (old: {
            patches =
              (old.patches or [])
              ++ [
                ../../combined-manager/nix-patches/evaluable-inputs.patch
              ];
          });
        })
      ];
    })
    (mkIf cfg.enable {
      os.nix = {
        enable = true;
        package = pkgs.nix-super;
        registry = mapAttrs (_name: value: {flake = value;}) (with inputs; {
          inherit nixpkgs;
          default = nixpkgs;
        });
        nixPath = [
          "nixpkgs=${inputs.nixpkgs}"
        ];
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        settings = {
          auto-optimise-store = true;
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
          substituters = [
            "https://nix-community.cachix.org"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
      };

      os.programs.command-not-found.enable = false;
      hm.programs.nix-index.enable = true;
    })
  ];
}
