{
  utils,
  secrets,
  pkgs,
  ...
}: let
  inherit (utils) domains;
in {
  os.environment.persistence = {
    "/persist2" = {
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
          directory = "/var/lib/mautrix-gmessages";
          user = "root";
          group = "root";
        }
        {
          directory = "/var/lib/mautrix-meta-instagram";
          user = "root";
          group = "root";
        }
        {
          directory = "/var/lib/matrix-appservice-irc";
          user = "root";
          group = "root";
        }
      ];
    };
  };

  services.postgres.enable = true;

  containers.maneVpn2 = {
    bindMounts = {
      "/var/lib/matrix-synapse".isReadOnly = false;
      "/var/lib/mautrix-whatsapp".isReadOnly = false;
      "/var/lib/mautrix-gmessages".isReadOnly = false;
      "/var/lib/mautrix-meta-instagram".isReadOnly = false;
      "/var/lib/matrix-appservice-irc".isReadOnly = false;
      ${secrets.matrix-sliding-sync}.isReadOnly = true;
    };
    config = _: {
      services.matrix = {
        enable = true;
        host = domains.personal;
      };
    };
  };
}
