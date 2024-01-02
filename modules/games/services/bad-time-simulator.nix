{
  inputs,
  lib,
  config,
  elib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.games.services.badTimeSimulator;
in {
  options.games.services.badTimeSimulator = {
    enable = mkEnableOption "badTimeSimulator";
  };

  config = mkMerge [
    {
      inputs.bad-time-simulator = {
        url = "github:flafydev/bad-time-simulator-compiled";
        flake = false;
      };
    }
    (
      mkIf cfg.enable {
        os.users = {
          users.badtimesimulator = {
            description = "Bad Time Simulator server service user";
            createHome = false;
            # home = cfg.dataDir;
            # homeMode = "770";
            isSystemUser = true;
            group = "badtimesimulator";
          };
          groups.badtimesimulator = { };
        };
        os.systemd.services.bad-time-simulator = {
          after = ["network.target"];
          description = "Start Bad Time Simulator server.";
          serviceConfig = {
            # username that systemd will look for; if it exists, it will start a service associated with that user
            User = "badtimesimulator";
            # the command to execute when the service starts up
            ExecStart = let
              script = pkgs.writeText "bts-python" ''
                import http.server
                import socketserver

                # Set the port number you want to use
                port = 8001

                # Choose the handler you want to use (in this case, SimpleHTTPRequestHandler)
                # handler = http.server.SimpleHTTPRequestHandler

                class CustomHandler(http.server.SimpleHTTPRequestHandler):
                    def __init__(self, *args, **kwargs):
                        super().__init__(*args, directory="${inputs.bad-time-simulator}", **kwargs)

                handler = CustomHandler


                # Create the server
                httpd = socketserver.TCPServer(("0.0.0.0", port), handler)

                # Print a message to indicate that the server is running
                print(f"Serving on port {port}")

                # Start the server
                httpd.serve_forever()
              '';
            in "${pkgs.python3}/bin/python ${script}";
          };
        };
      }
    )
  ];
}
