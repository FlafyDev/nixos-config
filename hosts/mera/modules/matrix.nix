{
  utils,
  secrets,
  pkgs,
  ...
}: let
  inherit (utils) domains;
in {
  os.environment.persistence = {
    "/persist" = {
      directories = [
        {
          directory = "/var/lib/matrix-synapse";
          user = "root";
          group = "root";
        }
        {
          directory = "/var/lib/mautrix-whatsapp";
          user = "root";
          group = "root";
        }
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
    comb = {
      mautrix_gmessages = {
        # networkTrusted =
        #   true; # FIXME: Really really don't like this but the janitor doesn't actually support UNIX sockets unlike what it says..
        # autoCreate = false;
        initSql = ''
          CREATE ROLE "mautrix_gmessages" WITH LOGIN PASSWORD 'synapse';
          CREATE DATABASE "mautrix_gmessages" WITH
            OWNER "mautrix_gmessages"
            TEMPLATE template0
            ENCODING = "UTF8"
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
      };

      mautrix_whatsapp = {
        # networkTrusted =
        #   true; # FIXME: Really really don't like this but the janitor doesn't actually support UNIX sockets unlike what it says..
        # autoCreate = false;
        initSql = ''
          CREATE ROLE "mautrix_whatsapp" WITH LOGIN PASSWORD 'synapse';
          CREATE DATABASE "mautrix_whatsapp" WITH
            OWNER "mautrix_whatsapp"
            TEMPLATE template0
            ENCODING = "UTF8"
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
      };
      synapse = {
        # networkTrusted =
        #   true; # FIXME: Really really don't like this but the janitor doesn't actually support UNIX sockets unlike what it says..
        # autoCreate = false;
        initSql = ''
          CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
          CREATE DATABASE "matrix-synapse" WITH
            OWNER "matrix-synapse"
            TEMPLATE template0
            ENCODING = "UTF8"
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
      };
    };
  };

  services.matrix = {
    enable = true;
    host = domains.personal;
  };

  containers.maneVpn2 = {
    bindMounts = {
      "/var/lib/matrix-synapse".isReadOnly = false;
      "/var/lib/mautrix-whatsapp".isReadOnly = false;
      # "/var/lib/postgresql".isReadOnly = false;
      "/var/lib/emoji-drawing".isReadOnly = false;
      ${secrets.matrix-sliding-sync}.isReadOnly = true;
    };
    config = {...}: {
      os.services.nginx.virtualHosts = {
        ${domains.personal}.locations = {
          "= /.well-known/matrix/server".extraConfig = let
            # use 443 instead of the default 8008 port to unite
            # the client-server and server-server port for simplicity
            server = {"m.server" = "matrix.${domains.personal}:443";};
          in ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
          "= /.well-known/matrix/client".extraConfig =
            # ACAO required to allow element-web on any URL to request this json file
            ''
              access_log /var/log/nginx/matrix.access.log;
              add_header Content-Type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '${builtins.toJSON {
                "m.homeserver".base_url = "https://matrix.${domains.personal}";
                "m.identity_server".base_url = "https://vector.im";
                "org.matrix.msc3575.proxy".url = "https://matrix.${domains.personal}";
              }}';
            '';
        };
        "matrix.${domains.personal}" = {
          addSSL = true;
          # log for prom
          extraConfig = ''
            access_log /var/log/nginx/matrix.access.log;
          '';
          locations = {
            "/admin".root = pkgs.linkFarm "synapse-admin-routing" [
              {
                name = "admin";
                path = "${pkgs.synapse-admin}";
              }
            ];
            # "/".root = "${pkgs.callPackage aaaa}";

            # forward all Matrix API calls to synapse
            "/_matrix" = {
              proxyPass = "http://10.10.15.10:8008"; # without a trailing /
              extraConfig = ''
                proxy_send_timeout 100;
                client_max_body_size 50M;
              '';
            };
            "/_synapse".proxyPass = "http://10.10.15.10:8008";
          };
        };
      };
    };
    # config.services.matrix = {
    #   enable = true;
    #   host = domains.personal;
    # };
  };
}
