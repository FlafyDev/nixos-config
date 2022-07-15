
{ config, lib, pkgs, modulesPath, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplip
    ];
  };
}