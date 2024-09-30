{
  config,
  osConfig,
  pkgs,
  ...
}: {
  os.environment.persistence = {
    "/persist2" = {
      directories = [
        {
          directory = "/var/lib/nextcloud-data";
          user = "root";
          group = "root";
        }
        {
          directory = "/var/lib/redis-nextcloud";
          user = "root";
          group = "root";
        }
        {
          directory = "/var/lib/nextcloud";
          user = "root";
          group = "root";
        }
      ];
    };
  };
  networking.allowedPorts.tcp."5000" = ["*"];
  unfree.allowed = ["corefonts"];
  os.environment.etc."temp-nextcloud-admin-pass".text = "PWD";
  os.services = {
    nginx.virtualHosts."localhost".listen = [
      {
        addr = "0.0.0.0";
        port = 5000;
      }
    ];
    nextcloud = {
      enable = true;
      # hostName = "cloud.example.com";
      hostName = "localhost";
      settings.trusted_domains = ["localhost" "10.0.0.41"];
      datadir = "/var/lib/nextcloud-data";

      # Need to manually increment with every major upgrade.
      package = pkgs.nextcloud29;

      # Let NixOS install and configure the database automatically.
      database.createLocally = true;

      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;

      # Increase the maximum file upload size to avoid problems uploading videos.
      maxUploadSize = "16G";
      # https = true;

      autoUpdateApps.enable = true; # HMM.....
      extraAppsEnable = true;
      extraApps = with osConfig.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit calendar contacts mail notes;
      };

      config = {
        # overwriteProtocol = "https";
        defaultPhoneRegion = "IL";
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = "/etc/temp-nextcloud-admin-pass";
      };
    };

    # onlyoffice = {
    #   enable = true;
    #   # hostname = "onlyoffice.example.com";
    #   hostname = "localhost";
    # };
  };
}
