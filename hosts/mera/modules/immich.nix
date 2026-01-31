_: {
  os.environment.persistence = {
    "/persist2" = {
      directories = [
        {
          directory = "/var/lib/immich";
          user = "immich";
          group = "immich";
        }
      ];
    };
  };

  os.services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
  };
}