{ssh, utils, ...}: let
  inherit (utils) resolveHostname domains;
in {
  networking = {
    enable = true;
    wireguard = true;
  };

  setupVM = {
    enable = true;
    homeInterface = "enp14s0";
    homeSubnet = "10.0.0.0/24";
    vpnInterface = "wg_vps";
    vpnSubnet = "10.10.10.0/24";
    forceHomeIPs = [(resolveHostname domains.personal)];
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
      };
      "50-wg_vps" = {
        matchConfig.Name = "wg_vps";
        networkConfig = {
          Address = ["10.10.10.10/24"];
          IPv6AcceptRA = false;
          DHCP = "no";
        };
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
}
