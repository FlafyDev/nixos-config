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

  users.main = "vps";
  users.host = "mane";

  networking = {
    enable = true;
    vpsForwarding.mane.settings = {
      outgoingAddress = domains.personal;
      wireguardInterface = "wg_vps";
    };
  };

  # os.networking.nftables = {
  #   enable = true;
  #   tables = {
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
  #   };
  # };

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
