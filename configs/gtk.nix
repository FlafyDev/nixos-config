{
  home = { pkgs, ... }: {
    home.packages = [ pkgs.dconf ];
    dconf.enable = true;
    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-decoration-layout = ":menu"; # disable title bar buttons
      };
      theme = {
        name = "Flat-Remix-GTK-Green-Darkest";
        package = pkgs.flat-remix-gtk;
      };
    };
  };
}
