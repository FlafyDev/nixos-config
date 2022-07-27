{ config, lib, pkgs, modulesPath, ... }:

{
  home.packages = with pkgs; [
    wineWowPackages.staging
    winetricks
  ];
}