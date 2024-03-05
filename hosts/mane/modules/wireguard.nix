{
  ssh,
  utils,
  lib,
  ...
}: let
  inherit (utils) domains;
in {
  networking.allowedPorts.tcp."80" = ["*"];
  networking.allowedPorts.udp."51823" = ["*"];

  # os.networking.nftables = {
  #   enable = true;
  #   tables = {
  #     trafficForwarding = {
  #       name = "trafficforwarding";
  #       family = "inet";
  #       enable = true;
  #
  #       content = ''
  #         chain forwarding {
  #           type filter hook forward priority 0; policy drop;
  #
  #           # Drop invalid packets.
  #           ct state invalid drop
  #
  #           # Forward all established and related traffic.
  #           ct state established,related accept
  #
  #           # Forward WireGuard traffic.
  #           # Allow WireGuard traffic to access the internet via wan.
  #           iifname "ens3" oifname "wg_vpn" accept;
  #           iifname "wg_vpn" oifname "ens3" accept;
  #           accept;
  #         }
  #
  #         chain postrouting {
  #           type nat hook postrouting priority 100;
  #
  #           # Masquerade WireGuard traffic.
  #           # All WireGuard traffic will look like it comes from the servers IP address.
  #           oifname ens3 ip saddr 10.10.12.13/32 masquerade
  #         }
  #       '';
  #     };
  #   };
  # };

  os.networking.nftables = {
    enable = true;
    tables = {
      main = {
        name = "main";
        family = "inet";
        enable = true;

        content = ''
          chain forwarding {
            type filter hook forward priority 0; policy drop;

            # Drop invalid packets.
            ct state invalid drop

            # Forward all established and related traffic.
            ct state established,related accept

            # Forward WireGuard traffic.
            # Allow WireGuard traffic to access the internet via wan.
            iifname "ens3" oifname "wg_vpn" accept;
            iifname "wg_vpn" oifname "ens3" accept;
            iifname "ens3" accept;
          }

          chain postrouting {
            type nat hook postrouting priority 100;

            # Masquerade WireGuard traffic.
            # All WireGuard traffic will look like it comes from the servers IP address.
            oifname ens3 ip saddr 10.10.12.1/32 masquerade
          }
        '';
      };
    };
  };

  networking = {
    enable = true;
    vpsForwarding.mane.settings = {
      excludeInterfaces = ["wg_vpn"];
    };
  };

  os.networking.wireguard = {
    enable = true;

    # interfaces.wg_vpn = {
    #   ips = ["10.10.12.1/32"];
    #   listenPort = 51823;
    #   privateKeyFile = ssh.mane.mane_wg_vpn.private;
    #   peers = [
    #     {
    #       publicKey = builtins.readFile ssh.mera.mera_wg_vpn.public;
    #       allowedIPs = ["10.10.12.11/32"];
    #       persistentKeepalive = 25;
    #       # allowedIPs = ["0.0.0.0/0" "::/0"];
    #     }
    #   ];
    # };
    interfaces.wg_vps = {
      ips = ["10.10.10.1/24"];
      listenPort = 51820;
      privateKeyFile = ssh.mane.mane_wg_vps.private;
      peers = [
        {
          publicKey = builtins.readFile ssh.ope.ope_wg_vps.public;
          allowedIPs = ["10.10.10.10/32"];
          # allowedIPs = ["0.0.0.0/0" "::/0"];
        }
        {
          publicKey = builtins.readFile ssh.mera.mera_wg_vps.public;
          allowedIPs = ["10.10.10.11/32"];
        }
      ];
    };
  };

  networking.allowedPorts.udp."51820,51822" = [domains.personal];
}
