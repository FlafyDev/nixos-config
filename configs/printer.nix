{
  system = { pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        hplip
      ];
    };
  };
}