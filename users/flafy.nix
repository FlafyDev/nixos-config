{ config, lib, pkgs, ... }:
[
  # (import /configs/git.nix)
  (import ../configs/gnome.nix)
  (import ../configs/mpv.nix)
  (import ../config/nixpkgs.nix)
  {
    programs.home-manager = { enable = true; };
  }
]