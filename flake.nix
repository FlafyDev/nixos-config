{
  description = "A very basic flake";

  inputs = import ./utils/mk-system-inputs-init.nix {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix = {
      url = "github:flafydev/nix";
    };
    npm-buildpackage = {
      url = "github:serokell/nix-npm-buildpackage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hyprland = {
    #   url = "github:hyprwm/Hyprland";
    #   # inputs.nixpkgs.follows = "nixpkgs";
    # };
    nur = {
      url = "github:nix-community/NUR";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    webcord = {
      url = "github:fufexan/webcord-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discocss = {
      url = "github:fufexan/discocss/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sway-borders = {
      url = "github:fluix-dev/sway-borders";
      flake = false;
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
    cp-maps.url = "github:flafydev/cp-maps";
    # nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland"; };
    # # only needed if you use as a package set:
    # # nixpkgs-wayland.inputs.nixpkgs.follows = "cmpkgs";
    # nixpkgs-wayland.inputs.master.follows = "master";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
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
