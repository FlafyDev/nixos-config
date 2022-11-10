# HP Officejet 4500 g510g-m
{
  system = {pkgs, ...}: {
    hardware.sane = {
      enable = true;
      extraBackends = [pkgs.hplipWithPlugin];
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [
        hplip
      ];
    };
  };
}
