{
  home = { pkgs, ... }: {
    home.packages = [ pkgs.dconf ];
    dconf.enable = true;
    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-decoration-layout = ":menu"; # disable title bar buttons
        gtk-application-prefer-dark-theme = 1;
      };
      theme = {
        name = "Flat-Remix-GTK-Green-Dark";
        package = pkgs.flat-remix-gtk;
      };
    };
  };
}
