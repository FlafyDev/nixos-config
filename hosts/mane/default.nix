{
  pkgs,
  config,
  ssh,
  utils,
  lib,
  ...
}: let
  inherit (utils) domains;
  inherit (lib) optional pathExists;
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

  # os.networking.nftables = {
  #   enable = true;
  #   tables = lib.mkForce {
  #     limit_bandwidth = {
  #       name = "traceall";
  #       family = "ip";
  #       enable = true;
  #
  #       content = ''
  #         chain prerouting {
  #             type filter hook prerouting priority -350; policy accept;
  #             meta nftrace set 1
  #         }
  #
  #         chain output {
  #             type filter hook output priority -350; policy accept;
  #             meta nftrace set 1
  #         }
  #       '';
  #     };
  #     tunnel = {
  #       name = "tunnel";
  #       family = "inet";
  #       enable = true;
  #
  #       content = ''
  #         chain prerouting {
  #           type nat hook prerouting priority 0 ;
  #
  #           tcp dport 5000 dnat ip to 10.10.10.10:5000
  #         }
  #
  #         chain postrouting {
  #           type nat hook postrouting priority 100 ;
  #
  #           oifname ens3 ip saddr 10.10.10.10 masquerade
  #         }
  #         chain input {
  #           type filter hook input priority 0; policy accept;
  #           accept
  #         }
  #
  #         chain forward {
  #           type filter hook forward priority 0; policy accept;
  #           accept
  #         }
  #
  #         chain output {
  #           type filter hook output priority 0; policy accept;
  #           accept
  #         }
  #       '';
  #     };
  #   };
  # };
  #
  # # TEMP22
  # networking.allowedPorts.tcp."5000" = ["*"];

  networking.forwardPorts."10.10.10.10".tcp = ["5000"];
  networking.forwardPorts."10.10.10.10".masquerade = false;
  networking.allowedPorts.tcp."5000" = ["*"];

  networking.enable = true;

  users.main = "vps";
  users.host = "mane";

  os = {
    services = {
      grafana = {
        enable = true;
        settings = {
          server = rec {
            http_addr = "0.0.0.0";
            http_port = 4000;
            domain = domains.personal;
            root_url = "http://${domain}:4000/"; # Not needed if it is `https://your.domain/`
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
    };
  };

  os.virtualisation.digitalOcean.setSshKeys = false;

  os.system.stateVersion = "23.05";
  hm.home.stateVersion = "23.05";

  secrets.enable = true;

  programs.nix.enable = true;
  programs.git.enable = true;
}
