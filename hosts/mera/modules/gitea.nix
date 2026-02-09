{
  os.environment.persistence = {
    "/persist2" = {
      directories = [
        {
          directory = "/var/lib/gitea";
          user = "gitea";
          group = "gitea";
        }
      ];
    };
  };

  os.services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    lfs.enable = true;
    settings.server.DOMAIN = "10.0.0.41";
  };
}
