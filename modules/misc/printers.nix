# HP Officejet 4500 g510g-m
{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.printers;
in {
  options.printers = {
    enable = mkEnableOption "printers";
  };

  config = mkIf cfg.enable {
    unfree.allowed = ["hplip"];

    sys = {
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
