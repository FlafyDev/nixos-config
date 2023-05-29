# HP Officejet 4500 g510g-m
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.printers;
  inherit (lib) mkEnableOption mkIf;
in {
  options.printers = {
    enable = mkEnableOption "printers";
  };

  config = mkIf cfg.enable {
    unfree.allowed = ["hplip"];

    os = {
      hardware.sane = {
        enable = true;
        extraBackends = [pkgs.hplipWithPlugin];
      };

      services = {
        printing = {
          enable = true;
          drivers = with pkgs; [
            hplip
            hplipWithPlugin
          ];
        };
        avahi.enable = true;
        ipp-usb.enable = true;
      };
    };
  };
}
