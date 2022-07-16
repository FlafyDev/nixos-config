{ config, lib, pkgs, modulesPath, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}