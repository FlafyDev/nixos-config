{
  description = "A very basic flake";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = github:nix-community/NUR;
  };

  outputs = { self, utils, nixpkgs, home-manager, nur, ... }@inputs: 
  let
    overlays = [
      nur.overlay
      (final: prev: let 
        inherit (prev) callPackage;
      in {
        mpvScripts = prev.mpvScripts // {
          mytestt = callPackage ./packages/mpv/scripts/modern-x-compact.nix { };
        };
      })
    ];
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem (
        import ./systems/laptop
          ((import ./profiles/normal.nix home-manager) ++ [
            ({ ... }: { nixpkgs.overlays = overlays; })
          ])
      );
    };
  };
}
