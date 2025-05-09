{
  pkgs,
  lib,
  config,
  osConfig,
  secrets,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.services.matrix;
in {
  options.services.matrix = {
    enable = mkEnableOption "matrix";
    postgresIP = mkOption {
      type = types.str;
      description = "The IP of the PostgreSQL server";
    };
    postgresPort = mkOption {
      type = types.str;
      default = "5432";
      description = "The port of the PostgreSQL server";
    };
    host = mkOption {
      type = types.str;
      description = "The domain name of the Matrix server";
    };
  };

  config = mkIf cfg.enable {
    insecure.allowed = [
      "olm-3.2.16"
    ];

    osModules = [
      ./mautrix-gmessages/service.nix
    ];

    services.postgres.comb = {
      mautrix_gmessages = {
        # networkTrusted =
        #   true; # FIXME: Really really don't like this but the janitor doesn't actually support UNIX sockets unlike what it says..
        # autoCreate = false;
        initSql = ''
          CREATE ROLE "mautrix-gmessages" WITH LOGIN PASSWORD 'synapse';
          CREATE DATABASE "mautrix-gmessages" WITH
            OWNER "mautrix-gmessages"
            TEMPLATE template0
            ENCODING = "UTF8"
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
      };
      matrix_irc = {
        # networkTrusted =
        #   true; # FIXME: Really really don't like this but the janitor doesn't actually support UNIX sockets unlike what it says..
        # autoCreate = false;
        initSql = ''
          CREATE ROLE "matrix-irc" WITH LOGIN PASSWORD 'synapse';
          CREATE DATABASE "matrix-irc" WITH
            OWNER "matrix-irc"
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
          CREATE ROLE "mautrix-whatsapp" WITH LOGIN PASSWORD 'synapse';
          CREATE DATABASE "mautrix-whatsapp" WITH
            OWNER "mautrix-whatsapp"
            TEMPLATE template0
            ENCODING = "UTF8"
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
      };
      mautrix_meta = {
        # networkTrusted =
        #   true; # FIXME: Really really don't like this but the janitor doesn't actually support UNIX sockets unlike what it says..
        # autoCreate = false;
        initSql = ''
          CREATE ROLE "mautrix-meta-instagram" WITH LOGIN PASSWORD 'synapse';
          CREATE DATABASE "mautrix-meta-instagram" WITH
            OWNER "mautrix-meta-instagram"
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

    os.services.matrix-synapse = {
      enable = true;
      settings = {
        media_retention.remote_media_lifetime = "30d";
        media_retention.local_media_lifetime = null;

        server_name = cfg.host;
        public_baseurl = "https://matrix.${cfg.host}/";
        database = {
          name = "psycopg2";
          args = {
            database = "matrix-synapse";
            user = "matrix-synapse";
            host = cfg.postgresIP;
            port = cfg.postgresPort;
          };
        };

        enable_registration = false;
        enable_registration_without_verification = false;

        redaction_retention_period = "3d";

        listeners = [
          {
            port = 8008;
            bind_addresses = ["::1"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = ["client" "federation"];
                # TODO: should this be compress true?
                compress = true;
              }
            ];
          }
        ];

        app_service_config_files = let
          doublePuppetingAppserviceYaml = pkgs.writeText "double-puppeting-registration.yaml" ''
            # The ID doesn't really matter, put whatever you want.
            id: doublepuppet
            # The URL is intentionally left empty (null), as the homeserver shouldn't
            # push events anywhere for this extra appservice. If you use a
            # non-spec-compliant server, you may need to put some fake URL here.
            url:
            # Generate random strings for these three fields. Only the as_token really
            # matters, hs_token is never used because there's no url, and the default
            # user (sender_localpart) is never used either.
            as_token: meow
            hs_token: meow2
            sender_localpart: meow3
            # Bridges don't like ratelimiting. This should only apply when using the
            # as_token, normal user tokens will still be ratelimited.
            rate_limited: false
            namespaces:
              users:
              # Replace your\.domain with your server name (escape dots for regex)
              - regex: '@.*:flafy\.dev'
                # This must be false so the appservice doesn't take over all users completely.
                exclusive: false
          '';
        in [
          # The registration file is automatically generated after starting the
          # appservice for the first time.
          # cp /var/lib/mautrix-telegram/telegram-registration.yaml \
          #   /var/lib/matrix-synapse/
          # chown matrix-synapse:matrix-synapse \
          #   /var/lib/matrix-synapse/telegram-registration.yaml
          # "/var/lib/matrix-synapse/telegram-registration.yaml"
          # "/var/lib/matrix-appservice-irc/registration.yml"
          # "/var/lib/mautrix-whatsapp/whatsapp-registration.yaml"
          "/var/lib/mautrix-gmessages/gmessages-registration.yaml"
          # automatically does that: (registerToSynapse)
          # "/var/lib/mautrix-meta-instagram/meta-registration.yaml"
          doublePuppetingAppserviceYaml
        ];
      };
    };

    os.users.users.matrix-synapse.extraGroups = [
      "mautrix-whatsapp"
      "mautrix-gmessages"
    ];

    os.services.nginx.virtualHosts = {
      ${cfg.host}.locations = {
        "= /.well-known/matrix/server".extraConfig = let
          # use 443 instead of the default 8008 port to unite
          # the client-server and server-server port for simplicity
          server = {"m.server" = "matrix.${cfg.host}:443";};
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
              "m.homeserver".base_url = "https://matrix.${cfg.host}";
              "m.identity_server".base_url = "https://vector.im";
              "org.matrix.msc3575.proxy".url = "https://matrix.${cfg.host}";
            }}';
          '';
      };
      "matrix.${cfg.host}" = {
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
            proxyPass = "http://[::1]:8008"; # without a trailing /
            extraConfig = ''
              proxy_send_timeout 100;
              client_max_body_size 50M;
            '';
          };

          "/_synapse".proxyPass = "http://[::1]:8008";

          # Matrix IRC media proxy
          "/_irc-media/" = {
            proxyPass = "http://[::1]:8007";
          };
        };
      };
    };

    # os.services.mautrix-meta = {
    #   instances = {
    #     instagram = {
    #       enable = true;
    #       registerToSynapse = true;
    #       settings = {
    #         homeserver = {
    #           address = "http://[::1]:8008";
    #           domain = cfg.host;
    #         };
    #         appservice = {
    #           database = {
    #             type = "postgres";
    #             uri = "postgres://${cfg.postgresIP}:${cfg.postgresPort}/mmmautrix-meta-instagram?sslmode=disable";
    #           };
    #         };
    #         bridge = {
    #           displayname_template = "{{or .DisplayName .Username \"Unknown user\"}} (IG)";
    #           delivery_receipts = true;
    #           login_shared_secret_map = {
    #             "flafy.dev" = "as_token:meow";
    #           };
    #           permissions = {
    #             ${cfg.host} = "user";
    #             "@admin:${cfg.host}" = "admin";
    #           };
    #         };
    #       };
    #     };
    #   };
    # };

    os.services.mautrix-gmessages = {
      enable = true;

      # file containing the appservice and telegram tokens
      # environmentFile = "/etc/secrets/mautrix-telegram.env";

      # The appservice is pre-configured to use SQLite by default.
      # It's also possible to use PostgreSQL.
      settings = {
        homeserver = {
          # address = "https://matrix.${cfg.host}";
          address = "http://[::1]:8008";
          domain = cfg.host;
        };
        appservice = {
          # hostname = "[::1]";
          database = {
            type = "postgres";
            uri = "postgres://${cfg.postgresIP}:${cfg.postgresPort}/mautrix-gmessages?sslmode=disable";
          };
        };
        bridge = {
          displayname_template = "{{or .FullName .PhoneNumber}} (SMS)";
          personal_filtering_spaces = true;
          delivery_receipts = true;
          message_error_notices = true;
          # hystory_sync = {
          #   backfill = true;
          #   request_full_sync = true;
          # };
          login_shared_secret_map = {
            "flafy.dev" = "as_token:meow";
          };
          # user_avatar_sync = true;
          # sync_with_custom_puppets = true;
          sync_direct_chat_list = true;
          sync_manual_marked_unread = true;
          private_chat_portal_meta = "always";
          mute_bridging = true;
          # parallel_member_sync = true;
          pinned_tag = "m.favourite";
          archive_tag = "m.lowpriority";
          # allow_user_invite = true;
          # url_previews = true;
          # extev_polls = true;
          # cross_room_replies = true;
          encryption = {
            allow = true;
            default = true;
            appservice = false;
            require = true;
            allow_key_sharing = true;
          };
          permissions = {
            ${cfg.host} = "user";
            "@admin:${cfg.host}" = "admin";
          };
        };
      };
    };

    # os.services.matrix-appservice-irc = {
    #   enable = true;
    #   needBindingCap = true; # to bind to ident on 113
    #
    #   settings = {
    #     homeserver = {
    #       url = "http://[::1]:8008";
    #       domain = cfg.host;
    #     };
    #     database = {
    #       engine = "postgres";
    #       connectionString = "postgres://${cfg.postgresIP}:${cfg.postgresPort}/mmatrix-irc?sslmode=disable";
    #     };
    #     ircService = {
    #       servers = {
    #         "irc.libera.chat" = {
    #           name = "Libera.Chat";
    #           address = "irc.libera.chat";
    #           port = 6667;
    #           tls = false;
    #           password = "";
    #           nick = "matrixbot";
    #           username = "matrixbot";
    #           realname = "Matrix IRC Bridge";
    #           joinChannels = ["#matrix"];
    #         };
    #       };
    #       mediaProxy = {
    #         bindPort = 8007;
    #         publicUrl = "https://matrix.${cfg.host}/_irc-media/";
    #         ttl = 0;
    #       };
    #       ident.enabled = true;
    #       permissions = {
    #         ${cfg.host} = "admin";
    #         "@admin:${cfg.host}" = "admin";
    #       };
    #     };
    #     # bridge = {
    #     #   displayname_template = "{{or .FullName .PushName .Phone .BusinessName .JID}} (IRC)";
    #     #   personal_filtering_spaces = true;
    #     #   delivery_receipts = true;
    #     #   message_error_notices = true;
    #     #   identity_change_notices = true;
    #     #   hystory_sync = {
    #     #     backfill = true;
    #     #     request_full_sync = true;
    #     #   };
    #     #   login_shared_secret_map = {
    #     #     "flafy.dev" = "as_token:meow";
    #     #   };
    #     #   user_avatar_sync = true;
    #     #   sync_with_custom_puppets = true;
    #     #   sync_direct_chat_list = true;
    #     #   sync_manual_marked_unread = true;
    #     #   private_chat_portal_meta = "always";
    #     #   mute_bridging = true;
    #     #   parallel_member_sync = true;
    #     #   pinned_tag = "m.favourite";
    #     #   archive_tag = "m.lowpriority";
    #     #   allow_user_invite = true;
    #     #   url_previews = true;
    #     #   extev_polls = true;
    #     #   cross_room_replies = true;
    #     #   encryption = {
    #     #     allow = true;
    #     #     default = true;
    #     #     appservice = false;
    #     #     require = true;
    #     #     allow_key_sharing = true;
    #     #   };
    #     #   permissions = {
    #     #     ${cfg.host} = "user";
    #     #     "@admin:${cfg.host}" = "admin";
    #     #   };
    #     #   relay.enabled = true;
    #     # };
    #   };
    # };

    os.services.mautrix-whatsapp = {
      enable = true;

      # file containing the appservice and telegram tokens
      # environmentFile = "/etc/secrets/mautrix-telegram.env";

      # The appservice is pre-configured to use SQLite by default.
      # It's also possible to use PostgreSQL.
      settings = {
        homeserver = {
          # address = "https://matrix.${cfg.host}";
          address = "http://[::1]:8008";
          domain = cfg.host;
        };
        appservice = {
          # hostname = "[::1]";
          database = {
            type = "postgres";
            uri = "postgres://${cfg.postgresIP}:${cfg.postgresPort}/mautrix-whatsapp?sslmode=disable";
          };
        };
        bridge = {
          displayname_template = "{{or .FullName .PushName .Phone .BusinessName .JID}} (WA)";
          personal_filtering_spaces = true;
          delivery_receipts = true;
          message_error_notices = true;
          identity_change_notices = true;
          hystory_sync = {
            backfill = true;
            request_full_sync = true;
          };
          login_shared_secret_map = {
            "flafy.dev" = "as_token:meow";
          };
          user_avatar_sync = true;
          sync_with_custom_puppets = true;
          sync_direct_chat_list = true;
          sync_manual_marked_unread = true;
          private_chat_portal_meta = "always";
          mute_bridging = true;
          parallel_member_sync = true;
          pinned_tag = "m.favourite";
          archive_tag = "m.lowpriority";
          allow_user_invite = true;
          url_previews = true;
          extev_polls = true;
          cross_room_replies = true;
          encryption = {
            allow = true;
            default = true;
            appservice = false;
            require = true;
            allow_key_sharing = true;
          };
          permissions = {
            ${cfg.host} = "user";
            "@admin:${cfg.host}" = "admin";
          };
          relay.enabled = true;
        };
      };
    };
  };
}
