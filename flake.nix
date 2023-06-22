{
  description = "NixOS configuration";

  inputs = let
    combinedManager = import ./combined-manager;
  in
    combinedManager.mkInputs {
      root = ./.;
      initialInputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        home-manager = {
          url = "github:nix-community/home-manager";
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
