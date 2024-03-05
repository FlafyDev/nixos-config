{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge;
  cfg = config.services.games.badTimeSimulator;
in {
  options.services.games.badTimeSimulator = {
    enable = mkEnableOption "badTimeSimulator";
    port = mkOption {
      type = types.int;
      default = 8001;
      description = "Port to run the server on.";
    };
    hostname = mkOption {
      type = types.str;
      default = "localhost";
      description = "Hostname to run the server on.";
    };
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
          groups.badtimesimulator = {};
        };
        os.systemd.services.bad-time-simulator = {
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          wants = ["network-online.target"];
          startLimitIntervalSec = 60;
          description = "Start Bad Time Simulator server.";
          serviceConfig = {
            Restart = "always";
            RestartSec = "10s";
            # username that systemd will look for; if it exists, it will start a service associated with that user
            User = "badtimesimulator";
            # the command to execute when the service starts up
            # ExecStart = pkgs.writeShellScript "exec-start" ''
            #                 ${pkgs.curl}/bin/curl https://myipv4.p1.opendns.com/get_my_ip
            #   nix run github:nixos/nixpkgs/nixpkgs-unstable#http-server
            # '';
            ExecStart = let
              script = pkgs.writeText "bts-python" ''
                from flask import Flask, request
                # import urllib.request
                # import json

                app = Flask(__name__)

                @app.route('/')
                def print_local_ips():
                    print("hmmmmmmmmmmm")
                    # Get the client's IP address
                    client_ip = request.remote_addr

                    # url = "https://myipv4.p1.opendns.com/get_my_ip"
                    #
                    # try:
                    #     with urllib.request.urlopen(url) as response:
                    #         data = json.loads(response.read().decode('utf-8'))
                    #         print(data)
                    # except urllib.error.HTTPError as e:
                    #     print(f"Error: Unable to fetch IP. Status code: {e.code}")
                    # except urllib.error.URLError as e:
                    #     print(f"Error: Unable to connect to the server. Reason: {e.reason}")

                    # Print the client's IP address to the console
                    print(f"Client IP: {client_ip}")
                    return str(client_ip)

                    # You can also get a list of all local IP addresses of the machine
                    # local_ips = [ip for ip in socket.gethostbyname_ex(socket.gethostname())[2] if not ip.startswith("127.")]
                    # print(f"Local IPs: {local_ips}")


                # if __name__ == '__main__':
                    # app.run(host="10.0.0.15", debug=True)
                app.run(host="${cfg.hostname}", port=${toString cfg.port}, debug=True)
              '';
            in "${pkgs.python3.withPackages (pyPkgs: with pyPkgs; [
              flask
            ])}/bin/python ${script}";
            # ExecStart = let
            #   script = pkgs.writeText "bts-python" ''
            #     import http.server
            #     import socketserver
            #
            #     # Set the port number you want to use
            #     port = ${toString cfg.port}
            #
            #     # Choose the handler you want to use (in this case, SimpleHTTPRequestHandler)
            #     # handler = http.server.SimpleHTTPRequestHandler
            #
            #     class CustomHandler(http.server.SimpleHTTPRequestHandler):
            #         def __init__(self, *args, **kwargs):
            #             super().__init__(*args, directory="${inputs.bad-time-simulator}", **kwargs)
            #
            #         def log_message(self, format, *args):
            #             # Get the client's IP address
            #             client_ip, _ = self.client_address
            #             # Print the client's IP along with the log message
            #             print(f"Client IP: {client_ip} - {format % args}")
            #
            #     handler = CustomHandler
            #
            #
            #     # Create the server
            #     httpd = socketserver.TCPServer(("${cfg.hostname}", port), handler)
            #
            #     # Print a message to indicate that the server is running
            #     print(f"Serving on port {port}")
            #
            #     # Start the server
            #     httpd.serve_forever()
            #   '';
            # in "${pkgs.python3}/bin/python ${script}";
          };
        };
      }
    )
  ];
}
