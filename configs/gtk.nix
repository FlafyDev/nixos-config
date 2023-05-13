{
  system = {pkgs, ...}: {
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  home = {pkgs, ...}: {
    home.packages = [pkgs.dconf];
    dconf.enable = true;
    gtk = {
      enable = true;

      gtk3.extraConfig = {
        gtk-decoration-layout = ":menu"; # disable title bar buttons
        gtk-application-prefer-dark-theme = 1;
      };

      cursorTheme = {
        name = "Bibata-Modern-Ice";
        size = 24;
        package = pkgs.bibata-cursors;
      };

      font = {
        name = "Roboto";
        package = pkgs.roboto;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "Tokyonight-Moon-BL"; # Moon = Night ?
        package = pkgs.tokyo-night-gtk;
      };
    };
  };
}
