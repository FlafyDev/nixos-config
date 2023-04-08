{
  system = _: {
    services.xserver = {
      enable = true;
      dpi = 96;

      displayManager.startx.enable = true;
      autorun = false;
    };
  };
}
