{
  add = _: {
    overlays = _: [
      (_final: prev: {
        nix = prev.nix.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              ./evaluable-inputs.patch
            ];
        });
      })
    ];
  };

  system = {inputs, ...}: {
    programs.command-not-found.enable = false;

    nix = {
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
  };

  home = _: {
    programs.nix-index.enable = true;
  };
}
