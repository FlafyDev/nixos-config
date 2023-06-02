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
          url = "github:nix-community/home-manager/c0deab0effd576e70343cb5df0c64428e0e0d010";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
      modules = [
        ./modules
        ./hosts/mera
        ./configs/flafy
      ];
    };

  outputs = inputs: let
    combinedManager = import ./combined-manager;
  in {
    nixosConfigurations = {
      mera = combinedManager.mkNixosSystem {
        system = "x86_64-linux";
        inherit inputs;
        modules = [
          ./modules
          ./hosts/mera
          ./configs/flafy
        ];
      };
    };
  };
}
