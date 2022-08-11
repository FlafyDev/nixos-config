{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    npm-buildpackage.url = "github:serokell/nix-npm-buildpackage";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    overlays = (import ./additions.nix).overlays inputs;
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem (
        import ./systems/laptop
          ((import ./profiles/normal.nix inputs) ++ [
            ({ ... }: { nixpkgs.overlays = overlays; })
          ])
      );
    };
  };
}
