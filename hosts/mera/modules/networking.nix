{utils, secrets, ...}: let
  inherit (utils) domains resolveHostname;
in
{
  networking = {
    enable = true;
    wireguard = true;
  };

  setupVM = {
    enable = true;
    homeInterface = "enp4s0";
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
        tcp dport 22 meta mark set 88    # SSH
        tcp dport 5000 meta mark set 88  # Nextcloud
        iifname enp4s0 tcp dport 5432 meta mark set 88  # Postgres
      }
    '';
  };

  os.systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  os.systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks = {
      "50-wlp3s0" = {
        matchConfig.Name = "wlp3s0";
        networkConfig.DHCP = "no";
        linkConfig.Unmanaged = "yes";
      };
      "50-enp4s0" = {
        matchConfig.Name = "enp4s0";
        networkConfig.DHCP = "yes";
        address = ["10.0.0.41/24"];
        dhcpV4Config = {
          RequestAddress = "10.0.0.41";
        };

        # linkConfig = {
        #   # Not here
        #   WakeOnLan = "magic";
        # };
      };
      "50-wg_vps" = {
        matchConfig.Name = "wg_vps";
        networkConfig = {
          Address = ["10.10.10.11/24"];
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
          PrivateKeyFile = secrets.ssh-keys.mera.mera_wg_vps.private;
        };
        wireguardPeers = [
          {
            PublicKey = secrets.ssh-keys.mane.mane_wg_vps.public.content;
            AllowedIPs = ["0.0.0.0/0"];
            Endpoint = "${resolveHostname domains.personal}:51820";
            PersistentKeepalive = 25;
          }
        ];
      };
    };
  };

  # os.networking = {
  #   wireguard = {
  #     enable = true;
  #     interfaces = {
  #       wg_vps = {
  #         ips = ["10.10.10.11/32"];
  #         privateKeyFile = ssh.mera.mera_wg_vps.private;
  #         peers = [
  #           {
  #             publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
  #             allowedIPs = ["0.0.0.0/0"];
  #             endpoint = "${resolveHostname domains.personal}:51820";
  #             persistentKeepalive = 25;
  #           }
  #         ];
  #       };
  #     };
  #     # wg_private = {
  #     #   ips = ["10.10.11.11/24"];
  #     #   privateKeyFile = ssh.mera.mera_wg_private.private;
  #     #   listenPort = 51821;
  #     #   peers = [
  #     #     {
  #     #       publicKey = builtins.readFile ssh.mane.mane_wg_private.public;
  #     #       allowedIPs = ["10.10.11.1/32"];
  #     #       endpoint = "${domains.personal}:51821";
  #     #     }
  #     #     {
  #     #       publicKey = builtins.readFile ssh.ope.ope_wg_private.public;
  #     #       allowedIPs = ["10.10.11.10/32"];
  #     #     }
  #     #   ];
  #     # };
  #   };
  # };

  # os.networking.nftables.tables = {
  #   filter = {
  #     content = ''
  #       # Check out https://wiki.nftables.org/ for better documentation.
  #       # Table for both IPv4 and IPv6.
  #       # Block all incoming connections traffic except SSH and "ping".
  #       chain input {
  #         type filter hook input priority 0;
  #
  #         # accept any localhost traffic
  #         iifname lo accept
  #
  #         # accept traffic originated from us
  #         ct state {established, related} accept
  #
  #         # ICMP
  #         # routers may also want: mld-listener-query, nd-router-solicit
  #         ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
  #         ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept
  #
  #         # allow "ping"
  #         ip6 nexthdr icmpv6 icmpv6 type echo-request accept
  #         ip protocol icmp icmp type echo-request accept
  #
  #         # accept incoming ports
  #         tcp dport 22 accept # SSH
  #         ## UNUSED: 5000-5999
  #         ## Nextcloud Lan
  #         ip saddr ${lan1Mask} tcp dport 5000 accept
  #
  #         # count and drop any other traffic
  #         counter drop
  #       }
  #
  #       # Allow all outgoing connections.
  #       chain output {
  #         type filter hook output priority 0;
  #         accept
  #       }
  #
  #       chain forward {
  #         type filter hook forward priority 0;
  #         accept
  #       }
  #
  #       chain postrouting {
  #         type nat hook postrouting priority -100;
  #
  #         # Forwarding incoming trafic from VPN interface to ISP networking
  #         iifname "vethhost0" snat ip to ${resolveHostname "mera.lan1"}
  #       }
  #     '';
  #     family = "inet";
  #   };
  # };
}
