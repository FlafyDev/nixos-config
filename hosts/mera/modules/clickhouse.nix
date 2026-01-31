{ pkgs, ... }:
let
in {
  os.environment.persistence = {
    "/persist2" = {
      directories = [{
        directory = "/var/lib/clickhouse";
        user = "clickhouse";
        group = "clickhouse";
      }];
    };
  };

  os.environment.etc = {
    "clickhouse-server/config.d/custom_path.xml" = {
      text = ''
        <clickhouse>
            <path>/var/lib/clickhouse/</path>
            <listen_host>0.0.0.0</listen_host>
        </clickhouse>
      '';
      user = "clickhouse";
      group = "clickhouse";
    };
    "clickhouse-server/users.d/showcase-user.xml" = {
      text = ''
        <clickhouse>
            <users>
                <default>
                  <password></password>
                  <networks>
                      <ip>::1</ip>
                      <ip>127.0.0.1</ip>
                  </networks>
                  <profile>default</profile>
                  <quota>default</quota>
                </default>

                <showcase>
                    <password>showcase</password>
                    <networks>
                        <ip>10.0.0.0/8</ip>
                    </networks>
                    <profile>default</profile>
                    <quota>default</quota>
                </showcase>
            </users>
          </clickhouse>
      '';
    };
  };

  os.services.clickhouse = { enable = true; };

  os.systemd.services.clickhouse-create-db = {
    description = "Create showcase database in ClickHouse";
    after = [ "clickhouse.service" ];
    wants = [ "clickhouse.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 5 && echo \"CREATE DATABASE IF NOT EXISTS showcase\" | ${pkgs.clickhouse}/bin/clickhouse-client'";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

