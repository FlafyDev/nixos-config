let
  combinedManager = import (builtins.fetchTarball {
    url = "https://github.com/flafydev/combined-manager/archive/9474a2432b47c0e6fa0435eb612a32e28cbd99ea.tar.gz";
    sha256 = "sha256:04rzv1ajxrcmjybk1agpv4rpwivy7g8mwfms8j3lhn09bqjqrxxf";
  });
in {
  description = "NixOS configuration";

  inputs = combinedManager.evaluateInputs {
    lockFile = ./flake.lock;
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

  outputs = inputs: {
    nixosConfigurations = {
      mera = combinedManager.nixosSystem {
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
