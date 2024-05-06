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
    host = mkOption {
      type = types.str;
      description = "The domain name of the Matrix server";
    };
  };

  config = mkIf cfg.enable {
    osModules = [
      ./mautrix-gmessages/service.nix
    ];


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
            host = "10.10.15.10";
          };
        };

        enable_registration = false;
        enable_registration_without_verification = false;

        redaction_retention_period = "3d";

        listeners = [
          {
            port = 8008;
            bind_addresses = ["10.10.15.10"];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = ["client" "federation"];
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
          # "/var/lib/mautrix-whatsapp/whatsapp-registration.yaml"
          # "/var/lib/mautrix-gmessages/gmessages-registration.yaml"
          # doublePuppetingAppserviceYaml
        ];
      };
      # ...
    };

    # os.users.users.matrix-synapse.extraGroups = [
    #   "mautrix-whatsapp"
    #   "mautrix-gmessages"
    # ];

    # os.services.nginx.virtualHosts = {
    #   ${cfg.host}.locations = {
    #     "= /.well-known/matrix/server".extraConfig = let
    #       # use 443 instead of the default 8008 port to unite
    #       # the client-server and server-server port for simplicity
    #       server = {"m.server" = "matrix.${cfg.host}:443";};
    #     in ''
    #       add_header Content-Type application/json;
    #       return 200 '${builtins.toJSON server}';
    #     '';
    #     "= /.well-known/matrix/client".extraConfig =
    #       # ACAO required to allow element-web on any URL to request this json file
    #       ''
    #         access_log /var/log/nginx/matrix.access.log;
    #         add_header Content-Type application/json;
    #         add_header Access-Control-Allow-Origin *;
    #         return 200 '${builtins.toJSON {
    #           "m.homeserver".base_url = "https://matrix.${cfg.host}";
    #           "m.identity_server".base_url = "https://vector.im";
    #           "org.matrix.msc3575.proxy".url = "https://matrix.${cfg.host}";
    #         }}';
    #       '';
    #   };
    #   "matrix.${cfg.host}" = {
    #     addSSL = true;
    #     # log for prom
    #     extraConfig = ''
    #       access_log /var/log/nginx/matrix.access.log;
    #     '';
    #     locations = {
    #       "/admin".root = pkgs.linkFarm "synapse-admin-routing" [
    #         {
    #           name = "admin";
    #           path = "${pkgs.synapse-admin}";
    #         }
    #       ];
    #       # "/".root = "${pkgs.callPackage aaaa}";
    #
    #       # forward all Matrix API calls to synapse
    #       "/_matrix" = {
    #         proxyPass = "http://10.10.15.10:8008"; # without a trailing /
    #         extraConfig = ''
    #           proxy_send_timeout 100;
    #           client_max_body_size 50M;
    #         '';
    #       };
    #       "/_synapse".proxyPass = "http://10.10.15.10:8008";
    #       "~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
    #         proxyPass = "http://${osConfig.services.matrix-sliding-sync.settings.SYNCV3_BINDADDR}";
    #       };
    #     };
    #   };
    # };

    # os.services.mautrix-gmessages = {
    #   enable = true;
    #
    #   # file containing the appservice and telegram tokens
    #   # environmentFile = "/etc/secrets/mautrix-telegram.env";
    #
    #   # The appservice is pre-configured to use SQLite by default.
    #   # It's also possible to use PostgreSQL.
    #   settings = {
    #     homeserver = {
    #       # address = "https://matrix.${cfg.host}";
    #       address = "http://[::1]:8008";
    #       domain = cfg.host;
    #     };
    #     appservice = {
    #       # hostname = "[::1]";
    #       database = {
    #         type = "postgres";
    #         uri = "postgres:///mautrix_gmessages?sslmode=disable&host=/run/postgresql";
    #       };
    #     };
    #     bridge = {
    #       displayname_template = "{{or .FullName .PhoneNumber}} (SMS)";
    #       personal_filtering_spaces = true;
    #       delivery_receipts = true;
    #       message_error_notices = true;
    #       # hystory_sync = {
    #       #   backfill = true;
    #       #   request_full_sync = true;
    #       # };
    #       login_shared_secret_map = {
    #         "flafy.dev" = "as_token:meow";
    #       };
    #       # user_avatar_sync = true;
    #       # sync_with_custom_puppets = true;
    #       sync_direct_chat_list = true;
    #       sync_manual_marked_unread = true;
    #       private_chat_portal_meta = "always";
    #       mute_bridging = true;
    #       # parallel_member_sync = true;
    #       pinned_tag = "m.favourite";
    #       archive_tag = "m.lowpriority";
    #       # allow_user_invite = true;
    #       # url_previews = true;
    #       # extev_polls = true;
    #       # cross_room_replies = true;
    #       encryption = {
    #         allow = true;
    #         default = true;
    #         appservice = false;
    #         require = true;
    #         allow_key_sharing = true;
    #       };
    #       permissions = {
    #         ${cfg.host} = "user";
    #         "@admin:${cfg.host}" = "admin";
    #       };
    #     };
    #   };
    # };

    # os.services.mautrix-whatsapp = {
    #   enable = true;
    #
    #   # file containing the appservice and telegram tokens
    #   # environmentFile = "/etc/secrets/mautrix-telegram.env";
    #
    #   # The appservice is pre-configured to use SQLite by default.
    #   # It's also possible to use PostgreSQL.
    #   settings = {
    #     homeserver = {
    #       # address = "https://matrix.${cfg.host}";
    #       address = "http://[::1]:8008";
    #       domain = cfg.host;
    #     };
    #     appservice = {
    #       # hostname = "[::1]";
    #       database = {
    #         type = "postgres";
    #         uri = "postgres:///mautrix_whatsapp?sslmode=disable&host=/run/postgresql";
    #       };
    #     };
    #     bridge = {
    #       displayname_template = "{{or .FullName .PushName .Phone .BusinessName .JID}} (WA)";
    #       personal_filtering_spaces = true;
    #       delivery_receipts = true;
    #       message_error_notices = true;
    #       identity_change_notices = true;
    #       hystory_sync = {
    #         backfill = true;
    #         request_full_sync = true;
    #       };
    #       login_shared_secret_map = {
    #         "flafy.dev" = "as_token:meow";
    #       };
    #       user_avatar_sync = true;
    #       sync_with_custom_puppets = true;
    #       sync_direct_chat_list = true;
    #       sync_manual_marked_unread = true;
    #       private_chat_portal_meta = "always";
    #       mute_bridging = true;
    #       parallel_member_sync = true;
    #       pinned_tag = "m.favourite";
    #       archive_tag = "m.lowpriority";
    #       allow_user_invite = true;
    #       url_previews = true;
    #       extev_polls = true;
    #       cross_room_replies = true;
    #       encryption = {
    #         allow = true;
    #         default = true;
    #         appservice = false;
    #         require = true;
    #         allow_key_sharing = true;
    #       };
    #       permissions = {
    #         ${cfg.host} = "user";
    #         "@admin:${cfg.host}" = "admin";
    #       };
    #       relay.enabled = true;
    #     };
    #   };
    # };

    os.services.matrix-sliding-sync = {
      enable = true;
      createDatabase = false;
      settings.SYNCV3_SERVER = "https://matrix.${cfg.host}";
      settings.SYNCV3_BINDADDR = "127.0.0.1:8009";
      environmentFile = secrets.matrix-sliding-sync;
    };
  };
}
