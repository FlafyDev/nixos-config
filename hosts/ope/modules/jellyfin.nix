_: {
  # networking.allowedPorts.tcp."8096" = ["*"];

  # os.services.plex = {
  #   enable = true;
  #   openFirewall = true;
  #   group="transmission";
  # };

  os.services.jellyfin = {
    enable = true;
    group = "transmission";
  };

  # os.users.users.jellyfin = {
  #   extraGroups = [
  #     "transmission"
  #   ];
  # };
}
