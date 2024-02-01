{
  pkgs,
  config,
  ssh,
  lib,
  ...
}: let
  inherit (lib) optional;
  inherit (builtins) pathExists;
in {
  osModules = [
    ({modulesPath, ...}: {
      imports =
        optional (pathExists ./do-userdata.nix) ./do-userdata.nix
        ++ [
          (modulesPath + "/virtualisation/digital-ocean-config.nix")
        ];
    })
  ];

  os = {
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            # Listening Address
            http_addr = "0.0.0.0";
            # and Port
            http_port = 4000;
            # Grafana needs to know on which domain and URL it's running
            domain = "flafy.me";
            root_url = "http://flafy.me:4000/"; # Not needed if it is `https://your.domain/`
            serve_from_sub_path = true;
          };
        };
      };
      prometheus = {
        enable = true;
        port = 4001;
        globalConfig = {
          scrape_interval = "15s";
          evaluation_interval = "15s";
        };
        scrapeConfigs = [
          {
            job_name = "main_pc";
            static_configs = [
              {
                targets = ["10.10.10.10:9100"];
              }
            ];
          }
        ];
      };
      # nginx = {
      #   enable = true;
      #   virtualHosts."flafy.me" = {
      #     locations."/" = {
      #       proxyPass = "https://10.10.10.10:443";
      #       extraConfig = ''
      #         proxy_set_header Host $host;
      #         proxy_set_header X-Real-IP $remote_addr;
      #         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #         proxy_set_header X-Forwarded-Proto $scheme;
      #       '';
      #     };
      #   };
      #   # streamConfig = ''
      #   #   server {
      #   #       listen 10.10.10.10:47984 tcp;  # Replace with the IP address assigned to the WireGuard interface
      #   #       proxy_pass flafy.me:47984;  # Replace with your actual service IP and port
      #   #   }
      #   #
      #   #   server {
      #   #       listen 10.10.10.10:47989 tcp;
      #   #       proxy_pass flafy.me:47989;
      #   #   }
      #   #
      #   #   server {
      #   #       listen 10.10.10.10:48010 udp;
      #   #       proxy_pass flafy.me:48010;
      #   #   }
      #   #
      #   #   server {
      #   #       listen 10.10.10.10:47998 udp;
      #   #       proxy_pass flafy.me:47998;
      #   #   }
      #   #
      #   #   server {
      #   #       listen 10.10.10.10:47999 udp;
      #   #       proxy_pass flafy.me:47999;
      #   #   }
      #   #
      #   #   server {
      #   #       listen 10.10.10.10:48000 udp;
      #   #       proxy_pass flafy.me:48000;
      #   #   }
      #   #
      #   #   server {
      #   #       listen 10.10.10.10:48002 udp;
      #   #       proxy_pass flafy.me:48002;
      #   #   }
      #   # '';
      # };

      vsftpd = {
        enable = true;
        #   cannot chroot && write
        #    chrootlocalUser = true;
        writeEnable = true;
        localUsers = true;
        # userlist = ["martyn" "cam"];
        # userlistEnable = true;
        # anonymousUserNoPassword = true;
        # anonymousUser = true;
      };
    };
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

    networking = {
      nftables = {
        enable = true;
        tables = {
          tunnel = {
            name = "tunnel";
            family = "ip";
            enable = true;

            # tcp dport 23-65535 dnat to 10.10.10.10:23-65535
            content = ''
              chain prerouting {
                  type nat hook prerouting priority 0 ;
                  tcp dport 80 dnat to 10.10.10.11:80
                  tcp dport 443 dnat to 10.10.10.11:443
                  udp dport 51821 dnat to 10.10.10.10:51821

                  tcp dport 47984 dnat to 10.10.10.10:47984
                  tcp dport 47989 dnat to 10.10.10.10:47989
                  tcp dport 48010 dnat to 10.10.10.10:48010

                  udp dport 47998-48000 dnat to 10.10.10.10:47998-48000
                  udp dport 48002 dnat to 10.10.10.10:48002
                  udp dport 48010 dnat to 10.10.10.10:48010
              }

              chain postrouting {
                  type nat hook postrouting priority 100 ;
                  masquerade
              }
            '';
          };
        };
      };
      firewall = {
        enable = true;
        allowedUDPPorts = [51820 48002 48010 51821];
        allowedTCPPorts = [80 443 48010 47989 47984 3001 4000 3004];
        allowedUDPPortRanges = [
          {
            from = 47998;
            to = 48000;
          }
        ];
      };
      wireguard = {
        enable = true;
        interfaces.wg_vps = {
          ips = ["10.10.10.1/24"];
          listenPort = 51820;
          privateKeyFile = ssh.mane.mane_wg_vps.private;
          peers = [
            {
              publicKey = builtins.readFile ssh.ope.ope_wg_vps.public;
              allowedIPs = ["10.10.10.10/32"];
            }
            {
              publicKey = builtins.readFile ssh.mera.mera_wg_vps.public;
              allowedIPs = ["10.10.10.11/32"];
            }
          ];
        };
      };
    };
  };

  os.virtualisation.digitalOcean.setSshKeys = false;

  os.system.stateVersion = "23.05";
  hm.home.stateVersion = "23.05";

  users.main = "vps";
  users.host = "mane";
  # os.networking.hostName = config.users.host;

  secrets.enable = true;
  # printers.enable = true;

  # bitwarden.enable = true;

  # os.services.openvscode-server = {
  #   enable = true;
  #   user = "server";
  #   withoutConnectionToken = true;
  #   package = pkgs.openvscode-server.overrideAttrs (old: {
  #     patches =
  #       (old.patches or [])
  #       ++ [
  #         ./temppatch.patch
  #       ];
  #   });
  #   # host = "0.0.0.0";
  #   # port = 58846;
  # };
  # os.nixpkgs.config.permittedInsecurePackages = [
  #   "nodejs-16.20.2"
  # ];

  # programs.neovim.enable = true;
  # programs.cli-utils.enable = true;
  # programs.transmission.enable = true;
  # programs.direnv.enable = true;
  # programs.fish.enable = true;
  # programs.git.enable = true;
  programs.nix.enable = true;
  programs.git.enable = true;
  programs.ssh = {
    enable = true;
    server = {
      enable = true;
      users.${config.users.main}.keyFiles = [
        ssh.ope.ope_to_mane.public
      ];
      users.root.keyFiles = [
        ssh.ope.ope_to_mane.public
      ];
    };
  };
  users.groups = ["sftpuser"];
}
