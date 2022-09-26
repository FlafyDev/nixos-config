{
  home = { pkgs, ... }: {
    qt = {
      enable = true;
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };
  };
}
