let
  combinedManager = import /home/flafy/repos/flafydev/combined-manager;
  # combinedManager = import (builtins.fetchTarball {
  #   url = "https://github.com/flafydev/combined-manager/archive/8a9043cdfa3596a4bd0e6c685726cfa7fdfa4e6d.tar.gz";
  #   sha256 = "sha256:1pvjn8j5rmr2g717bh1dgj6a8zi7ffmpm5nmhjrq1mcvbyi9kdyk";
  # });
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
      flake-parts.url = "github:hercules-ci/flake-parts";
    };

    configurations = {
      ope = {
        system = "x86_64-linux";
        modules = [
          ./modules
          ./hosts/ope
        ];
      };
      mera = {
        system = "x86_64-linux";
        modules = [
          ./modules
          ./hosts/mera
        ];
      };
      mane = {
        system = "x86_64-linux";
        modules = [
          ./modules
          ./hosts/mane
        ];
      };
      bara3 = {
        system = "aarch64-linux";
        modules = [
          ./modules
          ./hosts/bara
        ];
      };
      bara = {
        system = "aarch64-linux";
        inputOverrides = inputs: {
          # nixpkgs = inputs.mobile-nixos-nixpkgs;
          # home-manager = inputs.mobile-nixos-home-manager;
        };
        # useHomeManager = false;
        modules = [
          ./modules
          ./hosts/bara
        ];
      };
    };

    outputs = inputs @ {
      flake-parts,
      nixpkgs,
      ...
    }:
      flake-parts.lib.mkFlake {inherit inputs;} {
        flake.nixosConfigurations = {
          bara2 = inputs.mobile-nixos-nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = "oneplus-enchilada";})
              ({
                pkgs,
                lib,
                modules,
                ...
              }: {
                nixpkgs.config.allowUnfreePredicate = builtins.trace modules (pkg:
                  builtins.elem (lib.getName pkg) [
                    "oneplus-sdm845-firmware-xz"
                    "oneplus-sdm845-firmware"
                  ]);
              })
            ];
          };
        };
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        perSystem = {pkgs, ...}: {
          formatter = pkgs.alejandra;
        };
      };
  }
