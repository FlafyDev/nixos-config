{
  services.printing = {
    enable = true;
    drivers = [
      nixpkgs.hplip
    ];
  };
}