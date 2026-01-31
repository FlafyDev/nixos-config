{
  pkgs,
  ...
}: let
  definitionsJson = pkgs.writeText "definitions.json" ''
    {
      "vhosts": [
        { "name": "showcase" }
      ],
      "users": [
        {
          "name": "showcase",
          "password": "showcase",
          "tags": [
            "administrator"
          ]
        }
      ],
      "permissions": [
        {
          "user": "showcase",
          "vhost": "showcase",
          "configure": ".*",
          "write": ".*",
          "read": ".*"
        }
      ]
    }
  '';
in {
  os.services.rabbitmq = {
    enable = true;
    dataDir = "/persist2/var/lib/rabbitmq";
    managementPlugin.enable = true;
    listenAddress = "0.0.0.0";
    configItems = {
      "loopback_users.showcase" = "false";
      "log.console" = "true";
      "definitions.import_backend" = "local_filesystem";
      "definitions.local.path" = "${definitionsJson}";
    };
  };
}