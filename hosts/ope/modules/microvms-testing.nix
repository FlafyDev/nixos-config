{inputs, ...}: {
  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  osModules = [inputs.microvm.nixosModules.host];

  os.systemd.network = {
    networks = {
      # "10-lan" = {
      #   matchConfig.Name = ["enp14s0" "vm-*-lan"];
      #   networkConfig = {
      #     Bridge = "br-lan";
      #   };
      # };

      # "10-vpn" = {
      #   matchConfig.Name = ["wg_vps" "vm-*-vpn"];
      #   networkConfig = {
      #     Bridge = "br-vpn";
      #   };
      # };

      # "06-wg-vps-gretap" = {
      #   matchConfig.Name = "wg-vps-gretap";
      #   networkConfig = {
      #     Bridge = "br-vpn";
      #   };
      # };

      "50-vm0" = {
        matchConfig.Name = "vm0";
        networkConfig = {
          Address = ["10.10.15.1/30"];
          IPv6AcceptRA = false;
          DHCP = "no";
        };
      };

      # "10-lan-bridge" = {
      #   matchConfig.Name = "br-lan";
      #   networkConfig = {
      #     Address = ["10.0.0.42/24"];
      #     Gateway = "10.0.0.138";
      #     DNS = ["10.0.0.138"];
      #     IPv6AcceptRA = true;
      #     DHCP = "no";
      #   };
      #   linkConfig.RequiredForOnline = "routable";
      # };

      # "10-vpn-bridge" = {
      #   matchConfig.Name = "br-vpn";
      #   networkConfig = {
      #     Address = ["10.10.10.10/24"];
      #     # Gateway = "10.10.10.1";
      #     IPv6AcceptRA = false;
      #     DHCP = "no";
      #   };
      #   linkConfig.RequiredForOnline = "routable";
      # };
    };
  };

  os.microvm = {
    vms.vm0 = {
      autostart = true;
      restartIfChanged = true;
      config = {
        users.users.root = {
          group = "root";
          password = "itsfine";
          isSystemUser = true;
        };

        services.openssh = {
          enable = true;
          startWhenNeeded = true;
          settings.PermitRootLogin = "yes";
        };

        networking.useNetworkd = false;
        networking.firewall.enable = false;
        systemd.network = {
          enable = true;

          networks."20-lan" = {
            matchConfig.MACAddress = ["02:00:00:00:00:01"];
            matchConfig.Type = "ether";
            networkConfig = {
              Address = "10.10.15.2/30";
              Gateway = "10.10.15.1";
              DNS = "10.10.15.1";
              IPv6AcceptRA = true;
              DHCP = "no";
            };
          };
        };

        microvm = {
          interfaces = [
            {
              type = "tap";
              id = "vm0";
              mac = "02:00:00:00:00:01";
            }
          ];
          shares = [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
          ];
        };
      };
    };
  };
}
