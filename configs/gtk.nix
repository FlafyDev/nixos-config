{
  home = {pkgs, ...}: {
    home.packages = [pkgs.dconf];
    dconf.enable = true;
    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-decoration-layout = ":menu"; # disable title bar buttons
        gtk-application-prefer-dark-theme = 1;
      };
      font = {
        name = "Cantarell";
      };
      theme = {
        name = "Adwaita";
        package = pkgs.gnome.gnome-themes-extra;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
    };
  };
}
