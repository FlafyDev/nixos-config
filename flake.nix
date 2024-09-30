let
  combinedManager = import /home/flafy/repos/flafydev/combined-manager;
  # combinedManager = import (builtins.fetchTarball {
  #   url = "https://github.com/flafydev/combined-manager/archive/725f45b519187d6e1a49fe4d92b75d32b0d05687.tar.gz";
  #   sha256 = "sha256:0kkwx01m5a28sd0v41axjypmiphqfhnivl8pwk9skf3c1aarghfb";
  # });
in
  combinedManager.mkFlake {
    description = "NixOS configuration";

    lockFile = ./flake.lock;

    initialInputs = {
      # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      # nixpkgs-temp.url = "github:nixos/nixpkgs/b06025f1533a1e07b6db3e75151caa155d1c7eb3";
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
    # // {
    #   test = {
    #     system = "x86_64-linux";
    #     inputOverrides = inputs: {
    #       nixpkgs = inputs.nixpkgs-bara;
    #     };
    #     modules = [
    #       ({lib, ...}: {
    #         hm.home.stateVersion = "23.05";
    #         os.users.users.user.isNormalUser = true;
    #       })
    #     ];
    #   };
    # };

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
          lib,
          ...
        }: {
          formatter = pkgs.alejandra;
          packages = {
            bara-iso = self.nixosConfigurations.bara.config.mobile.outputs.default;
          };
        };
      };
  }
