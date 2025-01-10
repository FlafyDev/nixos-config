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

  # networking.notnft.namespaces.default.rules = with notnft.dsl; with payload; ruleset {
  #   filter = add table { family = f: f.inet; } {
  #     input = add chain { type = f: f.filter; hook = f: f.input; prio = 0; policy = f: f.accept; }
  #       [(is.eq tcp.dport 22) (mangle meta.mark 88)] # SSH
  #       ;
  #   };
  # };

  # networking.notnft.namespaces.default.rules = with notnft.dsl; with payload; ruleset {
  #   filter = add table { family = f: f.inet; } {
  #     input = add chain { type = f: f.filter; hook = f: f.input; prio = 0; policy = f: f.accept; }
  #       [(is.eq tcp.dport 22) (mangle meta.mark 88)] # SSH
  #       ;
  #   };
  # };

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
            AllowedIPs = ["10.10.10.1/32"];
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
