{
  system = { pkgs, ... }: {
    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    services.dbus.enable = true;
    # xdg.portal = {
    #   enable = true;
    #   wlr.enable = true;
    #   # gtk portal needed to make gtk apps happy
    #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    #   gtkUsePortal = true;
    # };

    # enable sway window manager
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };

  home = { pkgs, ... }: {
    wayland.windowManager.sway = {
      enable = true;
    };
  };
}
