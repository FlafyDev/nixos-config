{
  description = "A very basic flake";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, utils, nixpkgs, home-manager, ... }@inputs: 
  {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem ((import ./systems/laptop)
        ((import ./profiles/normal.nix) home-manager)
      );
    };
  };
}
