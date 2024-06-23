{...}: {
  os.environment.persistence = {
    "/persist" = {
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
