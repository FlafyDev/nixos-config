# Do not modify! This file is generated.

{
  description = "NixOS configuration";
  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };
    anyrun = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:kirottu/anyrun";
    };
    anyrun-nixos-options = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:n3oney/anyrun-nixos-options/v1.0.1";
    };
    assets.url = "github:FlafyDev/assets";
    bad-time-simulator = {
      flake = false;
      url = "github:flafydev/bad-time-simulator-compiled";
    };
    bufresize-nvim = {
      flake = false;
      url = "github:kwkarlwang/bufresize.nvim";
    };
    emoji-drawing.url = "github:flafydev/emoji-drawing";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-registry = {
      flake = false;
      url = "github:nixos/flake-registry";
    };
    flakegen.url = "github:jorsn/flakegen";
    flarrent = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:flafydev/flarrent";
    };
    flutter-hooks-snippets = {
      flake = false;
      url = "github:devmuaz/flutter-hooks-snippets";
    };
    flutter-riverpod-snippets = {
      flake = false;
      url = "github:RobertBrunhage/flutter-riverpod-snippets";
    };
    guifetch.url = "github:flafydev/guifetch";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    hypr-dynamic-cursors = {
      inputs.hyprland.follows = "hyprland";
      url = "github:VirtCode/hypr-dynamic-cursors";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    impermanence.url = "github:nix-community/impermanence";
    microvm = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "path:/home/flafy/repos/astro/microvm.nix";
    };
    mobile-nixos = {
      flake = false;
      url = "github:nixos/mobile-nixos/8f9ce9d7e7e71b2d018039332e04c5be78f0a6b7";
    };
    nix-gaming = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:fufexan/nix-gaming";
    };
    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Mic92/nix-index-database";
    };
    nix-minecraft.url = "github:infinidoge/nix-minecraft";
    nix-super = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:privatevoid-net/nix-super";
    };
    nixpak = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nixpak/nixpak";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-bara.url = "github:nixos/nixpkgs/684c17c429c42515bafb3ad775d2a710947f3d67";
    nixtheplanet.url = "github:matthewcroughan/nixtheplanet";
    nur.url = "github:nix-community/NUR";
    showcase.url = "git+file:///home/flafy/repos/flafydev/showcase2";
    tailwind-tools = {
      flake = false;
      url = "github:luckasRanarison/tailwind-tools.nvim";
    };
    transparent-nvim = {
      flake = false;
      url = "github:xiyaowong/transparent.nvim";
    };
  };
  outputs = inputs: inputs.flakegen ./flake.in.nix inputs;
}