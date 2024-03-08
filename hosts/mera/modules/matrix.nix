{
  utils,
  secrets,
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
          directory = "/var/lib/postgresql";
          user = "root";
          group = "root";
        }
      ];
    };
  };

  containers.maneVpn2 = {
    bindMounts = {
      "/var/lib/matrix-synapse".isReadOnly = false;
      "/var/lib/mautrix-whatsapp".isReadOnly = false;
      "/var/lib/postgresql".isReadOnly = false;
      "/var/lib/emoji-drawing".isReadOnly = false;
      ${secrets.matrix-sliding-sync}.isReadOnly = true;
    };
    config.services.matrix = {
      enable = true;
      host = domains.personal;
    };
  };
}
