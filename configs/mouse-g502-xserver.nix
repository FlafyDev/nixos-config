{
  system = { ... }: {
    services.xserver.libinput = {
      enable = true;

      mouse = {
        accelSpeed = "-0.78";
        accelProfile = "flat";
      };
    };
  };
}
