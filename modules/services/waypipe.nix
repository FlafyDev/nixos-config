{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge;
  cfg = config.services.waypipe;
in {
  # Currently a single host can only have a single server and client.
  # If I need to be able to have more servers/clients per host, then I'll change the module.
  options.services.waypipe = {
    server = {
      enable = mkEnableOption "waypipe-server";
      port = mkOption {
        type = types.int;
        default = 12345;
        description = "Port to run the server on.";
      };
    };
    client = {
      enable = mkEnableOption "waypipe-client";
      ip = mkOption {
        type = types.str;
        description = "IP of the remote server.";
      };
      port = mkOption {
        type = types.int;
        default = 12345;
        description = "Port of the remote server.";
      };
    };
  };

  config = mkMerge [
    (
      mkIf cfg.server.enable {
        os.systemd.services.waypipe-server = {
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          wants = ["network-online.target"];
          startLimitIntervalSec = 60;
          description = "Start Waypipe server";
          serviceConfig = {
            Restart = "always";
            RestartSec = "10s";
            DynamicUser = true;
            ExecStart = pkgs.writeShellScript "waypipe-server-script" ''
              rm /tmp/waypipe.sock
              ${pkgs.socat}/bin/socat TCP-LISTEN:${toString cfg.server.port},reuseaddr,fork UNIX-CONNECT:/tmp/waypipe.sock
            '';
          };
        };
      }
    )
    (
      mkIf cfg.client.enable {
        os.systemd.services.waypipe-client = {
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          wants = ["network-online.target"];
          startLimitIntervalSec = 60;
          description = "Start Waypipe server";
          serviceConfig = {
            Restart = "always";
            RestartSec = "10s";
            DynamicUser = true;
            ExecStart = pkgs.writeShellScript "waypipe-client-script" ''
              rm /tmp/waypipe.sock || true
              ${pkgs.waypipe}/bin/waypipe -s /tmp/waypipe.sock client &
              ${pkgs.socat}/bin/socat UNIX-LISTEN:/tmp/waypipe.sock,reuseaddr,fork TCP:${cfg.client.ip}:${toString cfg.client.port}
            '';
          };
        };
      }
    )
  ];
}

