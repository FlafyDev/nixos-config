{
  description = "A very basic flake";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, utils, nixpkgs, home-manager }: 
    # let
    #   mkHomeConfiguration = { username, configuratio, localOverlay }: home-manager.lib.homeManagerConfiguration (rec {
    #     system = "x86_64-linux";
    #     homeDirectory = "/home/" + username;
    #     username = username;
    #     configuration = configuration;
    #     pkgs = nixpkgs.legacyPackages.${system};
    #     args = {
    #       localOverlay = localOverlay;
    #     };
    #   });

    # in 
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./laptop/config.nix
            # home-manager.nixosModules.home-manager
            # {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.users.flafy = import ./users/flafy.nix;

            #   # Optionally, use home-manager.extraSpecialArgs to pass
            #   # arguments to home.nix
            # }
          ];
        };
      };
      # homeConfigurations.laptop = mkHomeConfiguration {
      #   username = "flafy";
      #   configuration = import ./config.nix;
      #   localOverlay = localOverlay;
      # };
    };
}
