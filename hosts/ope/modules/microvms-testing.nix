{inputs, ...}: {
  inputs.microvm.url = "github:astro/microvm.nix";
  inputs.microvm.inputs.nixpkgs.follows = "nixpkgs";

  osModules = [inputs.microvm.nixosModules.host];

  os.systemd.network = {
    networks = {
      "50-vm0" = {
        matchConfig.Name = "vm0";
        networkConfig = {
          Address = ["10.10.15.1/30"];
          IPv6AcceptRA = false;
          DHCP = "no";
        };
      };
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

  os.networking.nftables.tables.vm0 = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority 0 policy accept;

        # tcp dport 22 meta mark set 88
      }

      # Allow all outgoing connections.
      chain output {
        type filter hook output priority 0 policy accept;
        accept
      }

      chain forward {
        type filter hook forward priority 0 policy accept;
        accept
      }

      chain postrouting {
        type nat hook postrouting priority -100;

        iif vm0 ip daddr { 10.0.0.41 } dport { 5000 } snat to 10.0.0.42
        # iif vm0 snat to 10.0.0.42
      }
    '';
  };

}
