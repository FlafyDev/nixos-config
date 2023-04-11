{
  home = _: {
    services.picom = {
      enable = true;

      activeOpacity = 1.0;
      inactiveOpacity = 1.0;

      backend = "glx";
      vSync = true;
    };
  };
}
