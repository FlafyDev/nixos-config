let
  combinedManager = import /home/flafy/repos/flafydev/combined-manager;
  # combinedManager = import (builtins.fetchTarball {
  #   url = "https://github.com/flafydev/combined-manager/archive/c9cc0428a15d01417f96015f88fd874233b9cc42.tar.gz";
  #   sha256 = "sha256:188nwnr9vg4wwd98zm0fvwqwyraisaqqkxxlx1qm0x02pnbr904h";
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

    configurations = builtins.mapAttrs (host: cfg:
      cfg // {modules = [({lib, ...}: {imports = (import ./utils {inherit lib;}).getModulesForHost host;})];}) {
      ope.system = "x86_64-linux";
      mera.system = "x86_64-linux";
      mane.system = "x86_64-linux";
      bara.system = "aarch64-linux";
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

