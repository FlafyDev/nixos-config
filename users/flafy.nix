{ config, lib, pkgs, ... }:

{
  imports = [
    ../configs/gnome.nix
    ../configs/mpv.nix
    ../config/nixpkgs.nix
  ];

  programs.home-manager = { enable = true; };
}