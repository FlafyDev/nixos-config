let
  combinedManager = import (builtins.fetchTarball {
    url = "https://github.com/flafydev/combined-manager/archive/18fb4f6fd42bb6cceb9fc095897c1deb43f20c37.tar.gz";
    sha256 = "sha256:122m10sw1pm8zn6p4qyz7k4zrylibb4yvnsmyp6w23yy79zmrdhk";
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
      flake-parts.url = "github:hercules-ci/flake-parts";
    };

    configurations = builtins.mapAttrs (host: cfg:
      cfg // {modules = [({lib, ...}: {imports = (import ./utils {inherit lib;}).getModulesForHost host;})];}) {
      ope.system = "x86_64-linux";
      mera.system = "x86_64-linux";
      mane.system = "x86_64-linux";
      bara.system = "aarch64-linux";
      # bara.inputOverrides = inputs: {
      #   nixpkgs = inputs.nixpkgs-temp;
      # };
    };

    outputs = inputs @ {
      self,
      flake-parts,
      ...
    }:
      flake-parts.lib.mkFlake {inherit inputs;} {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        perSystem = {
          pkgs,
          ...
        }: {
          formatter = pkgs.alejandra;
          packages = {
            bara-iso = self.nixosConfigurations.bara.config.mobile.outputs.default;
          };
          devShells.default = pkgs.mkShell {
            packages = [pkgs.nixd pkgs.nil];
          };
        };
      };
  }
