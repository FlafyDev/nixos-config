{
  lib,
  secrets,
  utils,
  ...
}: let 
  inherit (utils) resolveHostname;
  hostIP = resolveHostname "mera.home";
in {
  services.postgres.comb = {
    showcase = {
      initSql = ''
        CREATE ROLE "showcase" WITH LOGIN PASSWORD 'showcase';
        CREATE DATABASE "showcase2" WITH
          OWNER "showcase"
          TEMPLATE template0
          ENCODING = "UTF8"
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };
  };

  os.environment.persistence = {
    "/persist2" = {
      directories = [{
        directory = "/var/lib/redis-showcase";
        user = "redis-showcase";
        group = "redis-showcase";
      }];
    };
  };

  os.services.redis.servers.showcase = {
    enable = true;
    bind = "0.0.0.0";
    port = 6379;
    user = "";
    requirePass = "showcase";
    settings = {
      dir = lib.mkForce "/var/lib/redis-showcase";
      dbfilename = "dump.rdb";
    };
  };

  setupGroups.groups."1" = {
    gateway = "vpn";
    helpers.namespace = "whatever";
    # interface = "vethaa5f730";
    inputRules = {interface, ...}: ''
      # Accept all packets from gp0 to host
      iifname ${interface} meta mark set 88
    '';
    forwardRules = {interface, ...}: ''
      # Accept all packets from host to gp0
      oifname ${interface} meta mark set 89
      # Accept all packets from gp0 to the host
      iifname ${interface} meta mark set 89
    '';
    extraPrerouting = {interface, ips}: ''
      iifname { wg_vps, enp4s0 } tcp dport 3333 dnat ip to ${ips.guest}
      iifname { enp4s0 } tcp dport 5123 dnat ip to ${ips.guest}:3000
      iifname { enp4s0 } tcp dport 9080 dnat ip to ${ips.guest}
    '';
  };

  os.services.showcaseServer = {
    enable = true;
    networkMode = "ns:/var/run/netns/whatever";
    envVars = {
      CLICKHOUSE_HOST = hostIP;
      CLICKHOUSE_PORT = "9000";
      CLICKHOUSE_DATABASE = "showcase";
      CLICKHOUSE_USER = "showcase";
      CLICKHOUSE_PASSWORD = "showcase";
      CLICKHOUSE_DOTENV = null;

      SQL_HOST = hostIP;
      SQL_PORT = "5432";
      SQL_DATABASE = "showcase2";
      SQL_USER = "showcase";
      SQL_PASSWORD = "showcase";
      SQL_DOTENV = null;

      RABBITMQ_HOST = hostIP;
      RABBITMQ_PORT = "5672";
      RABBITMQ_MANAGEMENT_PORT = "15672";
      RABBITMQ_DATABASE = "showcase";
      RABBITMQ_USER = "showcase";
      RABBITMQ_PASSWORD = "showcase";
      RABBITMQ_DOTENV = null;

      MINIO_HOST = hostIP;
      MINIO_PORT = "9002";
      MINIO_BUCKET = "showcase";
      MINIO_USER = "root";
      MINIO_PASSWORD = "rootpassword";
      MINIO_DOTENV = null;

      REDIS_HOST = hostIP;
      REDIS_PORT = "6379";
      REDIS_NAMESPACE = "";
      REDIS_USER = "default";
      REDIS_PASSWORD = "showcase";
      REDIS_DOTENV = null;

      DASHEND_BASE_URL = "http://localhost:6588/";
      DASHEND_DOTENV = null;

      SERVICE_DASHEND_DOTENV = secrets.dashend.envfile;

      GD_ABS_DIR = "/persist2/gd";
      EVALUATOR_DOCKER_IMAGE = "sha256:0ddd782ae8b3101c4d2f965ae1cd20952735fea96c6ba37c890e8edde652ebf6";
      EVALUATOR_REPLICAS = 1;
    };
    # gdDir = "/persist2/var/lib/showcase-server/gd";
  };

  services.postgres.comb = {
    showcase2 = {
      initSql = ''
        CREATE ROLE "showcase" WITH LOGIN PASSWORD 'showcase';
        CREATE DATABASE "showcase2" WITH
          OWNER "showcase"
          TEMPLATE template0
          ENCODING = "UTF8"
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
    };
  };
}
