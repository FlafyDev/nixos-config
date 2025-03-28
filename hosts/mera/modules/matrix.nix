{
  utils,
  secrets,
  pkgs,
  ...
}: let
  inherit (utils) resolveHostname domains;
in {
  setupVM.vms.vm0.config = {
    config = {
      services.matrix = {
        enable = true;
        postgresIP = resolveHostname "gateway.vm0";
        host = domains.personal;
      };
      os.microvm.shares = [
        {
          source = "/persist2/var/lib/matrix-synapse";
          mountPoint = "/var/lib/matrix-synapse";
          tag = "matrix-synapse";
          proto = "virtiofs";
        }
        {
          source = "/persist2/var/lib/mautrix-whatsapp";
          mountPoint = "/var/lib/mautrix-whatsapp";
          tag = "mautrix-whatsapp";
          proto = "virtiofs";
        }
        {
          source = "/persist2/var/lib/mautrix-gmessages";
          mountPoint = "/var/lib/mautrix-gmessages";
          tag = "mautrix-gmessages";
          proto = "virtiofs";
        }
        {
          source = "/persist2/var/lib/mautrix-meta-instagram";
          mountPoint = "/var/lib/mautrix-meta-instagram";
          tag = "mautrix-meta-instagram";
          proto = "virtiofs";
        }
        {
          source = "/persist2/var/lib/matrix-appservice-irc";
          mountPoint = "/var/lib/matrix-appservice-irc";
          tag = "matrix-appservice-irc";
          proto = "virtiofs";
        }
      ];
    };
  };
}
