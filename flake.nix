{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    npm-buildpackage = {
      url = "github:serokell/nix-npm-buildpackage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    webcord = {
      url = "github:fufexan/webcord-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discocss = {
      url = "github:fufexan/discocss/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yuck-vim = {
      url = "github:elkowar/yuck.vim"; 
      flake = false;
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bufresize-nvim = {
      url = "github:kwkarlwang/bufresize.nvim";
      flake = false; 
    };
    flutter-tools-nvim = {
      url = "github:FlafyDev/flutter-tools.nvim";
      flake = false;
    };
    lang-to-docx = {
      url = "github:FlafyDev/lang-to-docx";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem (
        (import ./profiles/i3.nix) (import ./systems/laptop) inputs
      );
    };
  };
}
