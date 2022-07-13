{
  description = "A very basic flake";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, utils, nixpkgs, home-manager }: 
    let
      localOverlay = prev: final: {};

      pkgsForSystem = system: import nixpkgs {
        overlays = [
          localOverlay
        ];
        inherit system;
      };

      mkHomeConfiguration = { username, configuratio, systemm, localOverlay }: home-manager.lib.homeManagerConfiguration (rec {
        system = systemm || "x86_64-linux";
        homeDirectory = "/home/" + username;
        username = username;
        configuration = configuration;
        pkgs = nixpkgs.legacyPackages.${system};
        args = {
          localOverlay = localOverlay;
        };
      });

    in utils.lib.eachSystem [ "x86_64-linux" ] {
      nixosConfigurations.laptop = mkHomeConfiguration {
        username = "flafy";
        configuration = import ./config.nix;
        localOverlay = localOverlay;
      };
      inherit home-manager;
    };
}
