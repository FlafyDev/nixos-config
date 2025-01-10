{ssh, utils, notnft, ...}: let
  inherit (utils) resolveHostname domains;
in {
  networking = {
    enable = true;
    vpnClient = {
      enable = true;
      forwardPortsOutOfNS = [ 8080 ];
    };
  };

  networking.notnft.namespaces.default.rules = with notnft.dsl; with payload; ruleset {
    filter = add table { family = f: f.inet; } {
      input = add chain { type = f: f.filter; hook = f: f.input; prio = 0; policy = f: f.accept; }
        [(is.eq tcp.dport 22) (mangle meta.mark 88)] # SSH
        ;
    };
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
        # networkConfig = {
        #   Address = ["10.0.0.42/24"];
        #   Gateway = "10.0.0.138";
        #   DNS = ["10.0.0.138"];
        #   IPv6AcceptRA = true;
        # };
        dhcpV4Config = {
          RequestAddress = "10.0.0.42";
        };

        # linkConfig = {
        #   # Not here
        #   WakeOnLan = "magic";
        # };
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
    # interfaces.enp14s0 = {
    #   ipv4.addresses = [
    #     {
    #       address = resolveHostname "ope.lan1";
    #       prefixLength = 24;
    #     }
    #   ];
    #   wakeOnLan.enable = true;
    # };
    # defaultGateway = {
    #   interface = "enp14s0";
    #   address = "10.0.0.138";
    # };
    useNetworkd = false;
    networkmanager = {
      enable = false;
    };

    # wireguard = {
    #   enable = true;
    #   interfaces = {
    #     wg_vps = {
    #       ips = ["10.10.10.10/32"];
    #       privateKeyFile = ssh.ope.ope_wg_vps.private;
    #       # interfaceNamespace = "vpn";
    #       # socketNamespace = "init";
    #       peers = [
    #         {
    #           publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
    #           allowedIPs = ["10.10.10.0/24"];
    #           endpoint = "${resolveHostname domains.personal}:51820";
    #           persistentKeepalive = 25;
    #         }
    #       ];
    #     };
    #     # wg_private = {
    #     #   ips = ["10.10.11.10/24"];
    #     #   privateKeyFile = ssh.ope.ope_wg_private.private;
    #     #   peers = [
    #     #     {
    #     #       publicKey = builtins.readFile ssh.mane.mane_wg_private.public;
    #     #       allowedIPs = ["10.10.11.1/32"];
    #     #       endpoint = "${domains.personal}:51821";
    #     #     }
    #     #     {
    #     #       publicKey = builtins.readFile ssh.mera.mera_wg_private.public;
    #     #       allowedIPs = ["10.10.11.11/32"];
    #     #       endpoint = "${resolveHostname "mera.lan1"}:51821";
    #     #     }
    #     #     # {
    #     #     #   publicKey = builtins.readFile ssh.mera.bara_wg_vps.public;
    #     #     #   allowedIPs = ["10.10.11.12/32"];
    #     #     # }
    #     #     # {
    #     #     #   publicKey = builtins.readFile ssh.mera.noro_wg_vps.public;
    #     #     #   allowedIPs = ["10.10.11.13/32"];
    #     #     # }
    #     #   ];
    #     # };
    #   };
    # };
  };
}
