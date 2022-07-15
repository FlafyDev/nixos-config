{ config, lib, pkgs, modulesPath, ... }:

{
  services = {
    xserver = {
      desktopManager.gnome.enable = true;
      displayManager.lightdm = {
        enable = true;
      };

      excludePackages = with pkgs; [
        xterm
      ];
    };
    
    gnome.core-utilities.enable = false;
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];
}