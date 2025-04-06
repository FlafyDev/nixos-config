_: {
  services.postgres.comb = {
    showcase = {
      initSql = ''
        CREATE ROLE "showcase" WITH LOGIN PASSWORD 'showcase';
        CREATE DATABASE "showcase" WITH
          OWNER "showcase"
          TEMPLATE template0
          ENCODING = "UTF8"
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };
  };


  os.services.showcaseServer = {
    enable = true;
    gdDir = "/persist2/var/lib/showcase-server/gd";
    postgres = {
      username = "showcase";
      password = "showcase";
    };
  };

  # os.environment.persistence = {
  #   "/persist2" = {
  #     hideMounts = true;
  #     directories = [
  #       {
  #         directory = "/var/lib/showcase-server";
  #         user = "root";
  #         group = "root";
  #       }
  #     ];
  #   };
  # };

  # containers.cShowcaseServer = {
  #   autoStart = true;
  #   extraFlags = ["--network-namespace-path=/run/netns/vpn"];

  #   bindMounts = {
  #     "/dev/dri".isReadOnly = false;
  #     "/run/opengl-driver".isReadOnly = false;
  #     "/run/user/1555".isReadOnly = false;
  #     "/var/lib/showcase-server".isReadOnly = false;
  #   };

  #   # TODO: try true
  #   ephemeral = false;

  #   config = {lib, ...}: {
  #     os = {
  #       hardware.graphics.enable = true;
  #       networking.firewall.enable = lib.mkForce false;

  #       services.showcaseServer = {
  #         enable = true;
  #       };

  #       systemd.services.showcase-server = {
  #         serviceConfig = {
  #           Restart = "always";
  #           RuntimeMaxSec = "1h";
  #         };
  #       };

  #       system.stateVersion = "24.05";
  #     };
  #   };
  # };
}
