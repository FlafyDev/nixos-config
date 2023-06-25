let
  combinedManager = import (builtins.fetchTarball {
    url = "https://github.com/flafydev/combined-manager/archive/71d2bc7553b59f69315328ba31531ffdc8c3ded2.tar.gz";
    sha256 = "sha256:0dkjcy3xknncl4jv0abqhqspnk91hf6ridb5xb7da5f29xn60mnf";
  });
in
  combinedManager.mkFlake {
    description = "NixOS configuration";

    lockFile = ./flake.lock;

    initialInputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
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
          ./configs/flafy
        ];
      };
    };
  }
