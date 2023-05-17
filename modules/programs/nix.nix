{
  inputs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.nix;
in {
  options.programs.nix = {
    enable = mkEnableOption "nix";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
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

    sys.nix = {
      enable = true;
      registry.nixpkgs.flake = inputs.nixpkgs;
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

    sys.programs.command-not-found.enable = false;
    home.programs.nix-index.enable = true;
  };
}
