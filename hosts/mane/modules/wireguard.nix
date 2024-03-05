{
  ssh,
  utils,
  lib,
  ...
}: let
  inherit (utils) domains;
in {
  os.networking.nftables = {
    enable = true;
    tables = {
      wireguard_tunnel = {
        name = "wireguard_tunnel";
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
            iifname "ens3" oifname "wg_vps" accept;
            iifname "wg_vps" oifname "ens3" accept;
            iifname "ens3" accept;
          }

          chain postrouting {
            type nat hook postrouting priority 100;

            # Masquerade WireGuard traffic.
            oifname "ens3" ip saddr 10.10.10.10 masquerade
          }
        '';
      };
    };
  };

  os.networking.wireguard = {
    enable = true;
    interfaces.wg_vps = {
      ips = ["10.10.10.1/24"];
      listenPort = 51820;
      privateKeyFile = ssh.mane.mane_wg_vps.private;
      peers = [
        {
          publicKey = builtins.readFile ssh.ope.ope_wg_vps.public;
          allowedIPs = ["10.10.10.10/32"];
        }
        {
          publicKey = builtins.readFile ssh.mera.mera_wg_vps.public;
          allowedIPs = ["10.10.10.11/32"];
        }
      ];
    };
  };

  networking.allowedPorts.udp."51820" = [domains.personal];
}
