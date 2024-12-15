{
  ssh,
  utils,
  lib,
  ...
}: let
  inherit (utils) domains;
in {
  # os.networking.nftables = {
  #   enable = true;
  #   tables = {
  #     wireguard_tunnel = {
  #       name = "wireguard_tunnel";
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
  #           iifname "ens3" oifname "wg_vps" accept;
  #           iifname "wg_vps" oifname "ens3" accept;
  #           iifname "ens3" accept;
  #         }
  #
  #         chain postrouting {
  #           type nat hook postrouting priority 100;
  #
  #           # Masquerade WireGuard traffic.
  #           oifname "ens3" ip saddr 10.10.10.0/24 masquerade
  #         }
  #       '';
  #     };
  #   };
  # };


  # networking.allowedPorts.udp = {
  #   "51820" = [domains.personal];
  #   "51821" = [domains.personal];
  # };
}
