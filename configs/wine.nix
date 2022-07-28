{
  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      wineWowPackages.staging
      winetricks
    ];
  };
}