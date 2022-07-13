nixpkgs: { username, system }: {
  nixpkgs.lib.nixosSystem {
    system = system;
    modules = [
      ./config.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${username} = import ./home.nix;

        # Optionally, use home-manager.extraSpecialArgs to pass
        # arguments to home.nix
      }
    ];
  }
}