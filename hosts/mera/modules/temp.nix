{
  ssh,
  pkgs,
  lib,
  utils,
  ...
}: let
  inherit (utils) domains;
in {
  # os.systemd.services = {
  #   postfix.serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  #   dovecot2.serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  #   opendkim.serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  #   bad-time-simulator.serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  #   # bad-time-simulator.serviceConfig.BindReadOnlyPaths = "/etc/netns/mynetns/resolv.conf:/etc/resolv.conf:norbind";
  # };
  #
  # networking.allowedPorts.tcp."5000" = ["*"];

  # os.networking.nftables = {
  #   enable = true;
  #   tables = lib.mkForce {
  #     limit_bandwidth = {
  #       name = "traceall";
  #       family = "ip";
  #       enable = true;
  #
  #       content = ''
  #         chain prerouting {
  #             type filter hook prerouting priority -350; policy accept;
  #             meta nftrace set 1
  #         }
  #
  #         chain output {
  #             type filter hook output priority -350; policy accept;
  #             meta nftrace set 1
  #         }
  #       '';
  #     };
  #     tunnel = {
  #       name = "tunnel";
  #       family = "inet";
  #       enable = true;
  #
  #       content = ''
  #         chain prerouting {
  #             type nat hook prerouting priority 0 ;
  #
  #             # iifname enp4s0 tcp dport 5000 snat ip to 10.0.0.15
  #             iifname enp4s0 tcp dport 5000 dnat ip to 10.10.14.2:5000
  #         }
  #
  #         chain postrouting {
  #             type nat hook postrouting priority 100 ;
  #
  #             # oifname vethhost0 masquerade
  #             # oifname vethhost0 ip saddr 10.0.0.15 ip daddr 10.10.14.2 masquerade
  #             # oifname vethhost0 snat ip to 10.10.14.1
  #
  #             # Additional rule for reverse translation
  #             # ip saddr 10.10.13.2 tcp sport 5000 snat to 10.0.0.2:5000
  #             # ip saddr 10.10.13.2 masquerade
  #             # iifname vethvpn0 masquerade
  #
  #             # oifname vethhost0 snat ip to 10.0.0.2
  #             
  #             # oifname vethhost0 snat ip to 10.10.14.1
  #
  #             # ip daddr 10.10.13.2 tcp dport 5000 snat to 10.0.0.2:5000
  #         }
  #         chain input {
  #           type filter hook input priority 0; policy accept;
  #         }
  #
  #         chain forward {
  #           type filter hook forward priority 0; policy accept;
  #         }
  #
  #         chain output {
  #           type filter hook output priority 0; policy accept;
  #         }
  #       '';
  #     };
  #   };
  # };

  # os.networking.wireguard = {
  #   enable = true;
  #   interfaces = {
  #     # wg_vpn = {
  #     #   ips = ["10.10.12.11/32"];
  #     #   privateKeyFile = ssh.mera.mera_wg_vpn.private;
  #     #   interfaceNamespace = "vpn";
  #     #   socketNamespace = "init";
  #     #   preSetup = let
  #     #     ip = "${pkgs.iproute2}/bin/ip";
  #     #   in ''
  #     #     ${ip} netns add vpn || true
  #     #     ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
  #     #     ${ip} link set vethvpn0 netns vpn || true
  #     #     ${ip} addr add 10.10.13.1/24 dev vethhost0 || true
  #     #     ${ip} netns exec vpn ip addr add 10.10.13.2/24 dev vethvpn0 || true
  #     #     ${ip} link set vethhost0 up || true
  #     #     ${ip} netns exec vpn ip link set vethvpn0 up || true
  #     #   '';
  #     #   peers = [
  #     #     {
  #     #       publicKey = builtins.readFile ssh.mane.mane_wg_vpn.public;
  #     #       allowedIPs = [
  #     #         "0.0.0.0/1"
  #     #         "128.0.0.0/3"
  #     #         "160.0.0.0/6"
  #     #         "164.0.0.0/7"
  #     #         "166.0.0.0/8"
  #     #         "167.0.0.0/10"
  #     #         "167.64.0.0/14"
  #     #         "167.68.0.0/15"
  #     #         "167.70.0.0/16"
  #     #         "167.71.0.0/19"
  #     #         "167.71.32.0/22"
  #     #         "167.71.36.0/25"
  #     #         "167.71.36.128/26"
  #     #         "167.71.36.192/28"
  #     #         "167.71.36.208/30"
  #     #         "167.71.36.212/32"
  #     #         "167.71.36.214/31"
  #     #         "167.71.36.216/29"
  #     #         "167.71.36.224/27"
  #     #         "167.71.37.0/24"
  #     #         "167.71.38.0/23"
  #     #         "167.71.40.0/21"
  #     #         "167.71.48.0/20"
  #     #         "167.71.64.0/18"
  #     #         "167.71.128.0/17"
  #     #         "167.72.0.0/13"
  #     #         "167.80.0.0/12"
  #     #         "167.96.0.0/11"
  #     #         "167.128.0.0/9"
  #     #         "168.0.0.0/5"
  #     #         "176.0.0.0/4"
  #     #         "192.0.0.0/2"
  #     #       ];
  #     #       endpoint = "${domains.personal}:51823";
  #     #       persistentKeepalive = 25;
  #     #     }
  #     #   ];
  #     # };
  #   };
  # };
}
