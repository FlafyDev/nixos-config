{
  description = "A very basic flake";

  inputs = import ./utils/mk-system-inputs-init.nix {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem (
        import ./profiles/wayland.nix {
          inherit inputs;
          system = import ./systems/laptop;
        }
      );
    };
  };
}
