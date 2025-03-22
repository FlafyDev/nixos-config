{ssh, utils, ...}: let
  inherit (utils) resolveHostname domains;
in {
  networking = {
    enable = true;
    vpnClient = {
      enable = true;
      forwardPortsOutOfNS = [ 8080 ];
    };
  };

  os.networking.nftables.tables.allow-services = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority 0; policy accept;
        meta nftrace set 1
        tcp dport 22 meta mark set 88 # SSH
        tcp dport 8080 meta mark set 88 # Testing
      }
      chain output {
        type filter hook output priority 0; policy accept;
        meta nftrace set 1
      }
    '';
  };


  os.systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  os.systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks = {
      "50-vethhost0" = {
        matchConfig.Name = "vethhost0";
        # networkConfig.DHCP = "no";
        linkConfig.Unmanaged = "yes";
      };
      "50-wlp15s0" = {
        matchConfig.Name = "wlp15s0";
        networkConfig.DHCP = "no";
        linkConfig.Unmanaged = "yes";
      };
      "50-enp14s0" = {
        matchConfig.Name = "enp14s0";
        networkConfig.DHCP = "yes";
        address = ["10.0.0.42/24"];
        dhcpV4Config = {
          RequestAddress = "10.0.0.42";
        };
        routes = [
          # Route traffic destined to the vps's IP not through the vps (for example, through home router).
          {
            Destination = "${resolveHostname domains.personal}";
            Table = 2;
            Gateway = "_dhcp4";
          }
          # Don't route traffic destined to LAN through the vps.
          {
            Destination = "10.0.0.0/24";
            Table = 2;
            Scope = "link";
          }
        ];
      };
      "50-wg_vps" = {
        matchConfig.Name = "wg_vps";
        networkConfig = {
          Address = ["10.10.10.10/24"];
          IPv6AcceptRA = false;
          DHCP = "no";
        };
        routes = [
          {
            Destination = "0.0.0.0/0";
            Table = 2;
            Scope = "link";
          }
        ];
        routingPolicyRules = [
          # Make sure all traffic that comes from 10.10.10.10/24 goes to table 2 (to get oif wg_vps)
          {
            Family = "ipv4";
            From = "10.10.10.10/24";
            Table = 2;
          }
        ];
      };
    };
    netdevs = {
      "50-wg_vps" = {
        netdevConfig = {
          Name = "wg_vps";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = ssh.ope.ope_wg_vps.private;
        };
        wireguardPeers = [
          {
            PublicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
            AllowedIPs = ["0.0.0.0/0"];
            Endpoint = "${resolveHostname domains.personal}:51820";
            PersistentKeepalive = 25;
          }
        ];
      };
    };
  };

  os.networking = {
    useNetworkd = false;
    networkmanager = {
      enable = false;
    };
  };
}
