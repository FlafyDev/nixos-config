_: {
  # networking.allowedPorts.tcp."8096" = ["*"];

  os.services.jellyfin = {
    enable = true;
    group = "transmission";
  };

  os.users.users.jellyfin = {
    extraGroups = [
      "transmission"
    ];
  };
}
