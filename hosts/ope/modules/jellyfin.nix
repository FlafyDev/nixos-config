_: {
  networking.allowedPorts.tcp."8096" = ["*"];

  os.services.jellyfin = {
    enable = true;
  };

  os.users.users.jellyfin = {
    extraGroups = [
      "transmission"
    ];
  };
}
