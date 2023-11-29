let
  # combinedManager = import /home/flafy/repos/flafydev/combined-manager;
  combinedManager = import (builtins.fetchTarball {
    url = "https://github.com/flafydev/combined-manager/archive/71d2bc7553b59f69315328ba31531ffdc8c3ded2.tar.gz";
    sha256 = "sha256:0dkjcy3xknncl4jv0abqhqspnk91hf6ridb5xb7da5f29xn60mnf";
  });
in
  combinedManager.mkFlake {
    description = "NixOS configuration";

    lockFile = ./flake.lock;

    initialInputs = {
      nixpkgs.url = "github:nixos/nixpkgs/970a59bd19eff3752ce552935687100c46e820a5";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      flake-parts.url = "github:hercules-ci/flake-parts";
    };

    configurations = {
      ope = {
        system = "x86_64-linux";
        modules = [
          ./modules
          ./hosts/ope
          ./configs/flafy
        ];
      };
      mera = {
        system = "x86_64-linux";
        modules = [
          ./modules
          ./hosts/mera
          ./configs/server
        ];
      };
    };

    outputs = inputs @ {flake-parts, ...}:
      flake-parts.lib.mkFlake {inherit inputs;} {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        perSystem = {pkgs, ...}: {
          formatter = pkgs.alejandra;
        };
      };
  }
