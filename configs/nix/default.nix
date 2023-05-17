{
  inputs = {
    dart-flutter.url = "path:/mnt/general/repos/flafydev/dart-flutter-nix";
    # dart-flutter.inputs.nixpkgs.follows = "nixpkgs";
    dart-flutter.inputs.nixpkgs-small.follows = "nixpkgs-small";
  };

  add = {dart-flutter, ...}: {
    overlays = _: [
      dart-flutter.overlays.default
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

  system = {
    inputs,
    pkgs,
    ...
  }: {
    programs.command-not-found.enable = false;
    environment.systemPackages = with pkgs; [
      flutter
    ];

    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;
      registry.dart-flutter.flake = inputs.dart-flutter;
      registry.nixpkgs-small.flake = inputs.nixpkgs-small;
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
