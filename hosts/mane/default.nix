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

  users.main = "vps";
  users.host = "mane";

  networking = {
    enable = true;
    vpsForwarding.mane.settings = {
      outgoingAddress = "flafy.me";
      wireguardInterface = "wg_vps";
    };
  };

  os = {
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "0.0.0.0";
            http_port = 4000;
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
    };
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    networking.firewall.enable = true;
  };

  os.virtualisation.digitalOcean.setSshKeys = false;

  os.system.stateVersion = "23.05";
  hm.home.stateVersion = "23.05";

  secrets.enable = true;

  programs.nix.enable = true;
  programs.git.enable = true;
}
