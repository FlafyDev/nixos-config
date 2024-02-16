# HP Officejet 4500 g510g-m
{
  pkgs,
  lib,
  config,
  osConfig,
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

    networking.allowedPorts.tcp."631" = ["*"];
    networking.allowedPorts.udp."631,5353" = ["*"];

    os = {
      system.nssModules = pkgs.lib.optional (!osConfig.services.avahi.nssmdns) pkgs.nssmdns;
      system.nssDatabases.hosts = with pkgs.lib;
        optionals (!osConfig.services.avahi.nssmdns) (mkMerge [
          (mkBefore ["mdns4_minimal [NOTFOUND=return]"]) # before resolve
          (mkAfter ["mdns4"]) # after dns
        ]);

      hardware.sane = {
        enable = true;
        extraBackends = [pkgs.hplipWithPlugin];
      };

      networking.firewall = {
        allowedTCPPorts = [631];
        allowedUDPPorts = [631 5353];
      };

      services = {
        avahi = {
          enable = true;
          nssmdns = false;
          publish = {
            enable = true;
            userServices = true;
          };
        };
        printing = {
          enable = true;
          drivers = with pkgs; [
            hplip
            hplipWithPlugin
          ];
        };
        ipp-usb.enable = true;
      };
    };
  };
}
