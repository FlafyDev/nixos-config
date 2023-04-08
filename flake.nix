{
  description = "A very basic flake";

  inputs = import ./utils/mk-system-inputs-init.nix {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem (
        import ./profiles/minimal.nix (import ./utils/mk-system.nix) {
          inherit inputs;
          system = import ./systems/laptop;
        }
      );
    };
  };
}
