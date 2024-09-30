{...}: {
  os.environment.persistence = {
    "/persist2" = {
      directories = [
        {
          directory = "/var/lib/postgresql";
          user = "root";
          group = "root";
        }
      ];
    };
  };

  services.postgres = {
    enable = true;
  };
}
