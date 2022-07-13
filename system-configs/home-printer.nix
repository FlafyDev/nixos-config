
{ config, lib, pkgs, modulesPath, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.hplip
    ];
  };
}