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
