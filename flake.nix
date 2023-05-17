{
  description = "NixOS configuration";

  inputs = let
    combinedManager = import ./combined-manager;
  in
    combinedManager.mkInputs {
      root = ./.;
      initialInputs = {
        nixpkgs.url = "github:nixos/nixpkgs/897876e4c484f1e8f92009fd11b7d988a121a4e7";
        home-manager = {
          url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
      modules = [./configuration.nix];
    };

  outputs = inputs: let
    combinedManager = import ./combined-manager;
  in {
    nixosConfigurations = {
      default = combinedManager.mkNixosSystem {
        system = "x86_64-linux";
        inherit inputs;
        modules = [./configuration.nix];
      };
    };
  };
}
