{
  inputs = {
    pkgs.url = "nixpkgs/nixos-21.11"; 
    unstable.url = "nixpkgs/nixos-unstable"; 
    home-manager.url = github:nix-community/home-manager;
  };
  
  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.fnord = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
