{
  ssh,
  utils,
  lib,
  pkgs,
  ...
}: let
  inherit (utils) domains resolveHostname;
in {
  # networking.vpsForwarding.mane.udp = ["5000"];

  # NetworkNamespacePath = "/var/run/netns/vpn";

  os.networking.nftables = {
    enable = true;
    tables = lib.mkForce {
      limit_bandwidth = {
        name = "traceall";
        family = "ip";
        enable = true;

        content = ''
          chain prerouting {
              type filter hook prerouting priority -350; policy accept;
              meta nftrace set 1
          }

          chain output {
              type filter hook output priority -350; policy accept;
              meta nftrace set 1
          }
        '';
      };
      tunnel = {
        name = "tunnel";
        family = "inet";
        enable = true;

        content = ''
          chain prerouting {
              type nat hook prerouting priority 0 ;

              iifname enp14s0 tcp dport 5000 dnat ip to 10.10.15.11:5000
          }

          chain postrouting {
              type nat hook postrouting priority 100 ;

              # Wireguard traffic
              oifname "enp14s0" ip saddr 10.10.10.10 masquerade

              # Masquerade LAN traffic to container
              oifname "vethhost0" ip daddr 10.10.15.0/24 masquerade
          }
          chain input {
            type filter hook input priority 0; policy accept;
          }

          chain forward {
            type filter hook forward priority 0; policy accept;
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };
    };
  };

  os.networking.wireguard = {
    enable = true;
    interfaces = {
      # wg_private = {
      #   listenPort = 51821;
      #   ips = ["10.10.11.10/32"];
      #   privateKeyFile = ssh.ope.ope_wg_private.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.bara.bara_wg_private.public;
      #       allowedIPs = ["10.10.11.12/32"];
      #       persistentKeepalive = 25;
      #     }
      #   ];
      # };

      # wg_vpn = let
      #   ip = "${pkgs.iproute2}/bin/ip";
      # in {
      #   ips = ["10.10.12.11/32"];
      #   privateKeyFile = ssh.mera.mera_wg_vpn.private;
      #   # interfaceNamespace = "vpn";
      #   # socketNamespace = "init";
      #   preSetup = ''
      #     # ${ip} netns add vpn || true
      #     ${ip} rule add from 10.10.12.11 table 123 priority 456 || true
      #
      #     # ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
      #     # ${ip} link set vethvpn0 netns vpn || true
      #     # ${ip} addr add 10.10.13.1/24 dev vethhost0 || true
      #     # ${ip} netns exec vpn ip addr add 10.10.13.2/24 dev vethvpn0 || true
      #     # ${ip} link set vethhost0 up || true
      #     # ${ip} netns exec vpn ip link set vethvpn0 up || true
      #   '';
      #   postSetup = ''
      #     ${ip} rule del from 10.10.12.11 table 123 priority 456
      #   '';
      #
      #   table = "123";
      #
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_vpn.public;
      #       allowedIPs = [
      #         "0.0.0.0/1"
      #         "128.0.0.0/3"
      #         "160.0.0.0/6"
      #         "164.0.0.0/7"
      #         "166.0.0.0/8"
      #         "167.0.0.0/10"
      #         "167.64.0.0/14"
      #         "167.68.0.0/15"
      #         "167.70.0.0/16"
      #         "167.71.0.0/19"
      #         "167.71.32.0/22"
      #         "167.71.36.0/25"
      #         "167.71.36.128/26"
      #         "167.71.36.192/28"
      #         "167.71.36.208/30"
      #         "167.71.36.212/32"
      #         "167.71.36.214/31"
      #         "167.71.36.216/29"
      #         "167.71.36.224/27"
      #         "167.71.37.0/24"
      #         "167.71.38.0/23"
      #         "167.71.40.0/21"
      #         "167.71.48.0/20"
      #         "167.71.64.0/18"
      #         "167.71.128.0/17"
      #         "167.72.0.0/13"
      #         "167.80.0.0/12"
      #         "167.96.0.0/11"
      #         "167.128.0.0/9"
      #         "168.0.0.0/5"
      #         "176.0.0.0/4"
      #         "192.0.0.0/2"
      #       ];
      #       endpoint = "${domains.personal}:51823";
      #       persistentKeepalive = 25;
      #     }
      #   ];
      # };
      wg_vps = let
        ip = "${pkgs.iproute2}/bin/ip";
      in {
        ips = ["10.10.10.10/32"];
        privateKeyFile = ssh.ope.ope_wg_vps.private;
        interfaceNamespace = "vpn";
        socketNamespace = "init";
        preSetup = ''
          ${ip} netns add vpn || true
          # ${ip} -n vpn rule add from 10.10.10.10 priority 456 || true

          ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
          ${ip} link set vethvpn0 netns vpn || true
          ${ip} addr add 10.10.15.10/24 dev vethhost0 || true
          ${ip} netns exec vpn ip addr add 10.10.15.11/24 dev vethvpn0 || true
          ${ip} link set vethhost0 up || true
          ${ip} netns exec vpn ip link set vethvpn0 up || true
        '';

        peers = [
          {
            publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "${domains.personal}:51820";
            persistentKeepalive = 25;
          }
        ];
      };
      # wg_vps = let
      #   ip = "${pkgs.iproute2}/bin/ip";
      # in {
      #   ips = ["10.10.10.10/32"];
      #   privateKeyFile = ssh.ope.ope_wg_vps.private;
      #   interfaceNamespace = "vpn";
      #   socketNamespace = "init";
      #   preSetup = ''
      #     ${ip} netns add vpn || true
      #     # ${ip} rule add from 10.10.10.10 table 123 priority 456 || true
      #     # ${ip} rule add from 10.10.15.11 table 123 priority 457 || true
      #   '';
      #
      #   # table = "123";
      #
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
      #       allowedIPs = [
      #         "0.0.0.0/1"
      #         "128.0.0.0/3"
      #         "160.0.0.0/6"
      #         "164.0.0.0/7"
      #         "166.0.0.0/8"
      #         "167.0.0.0/10"
      #         "167.64.0.0/14"
      #         "167.68.0.0/15"
      #         "167.70.0.0/16"
      #         "167.71.0.0/19"
      #         "167.71.32.0/22"
      #         "167.71.36.0/25"
      #         "167.71.36.128/26"
      #         "167.71.36.192/28"
      #         "167.71.36.208/30"
      #         "167.71.36.212/32"
      #         "167.71.36.214/31"
      #         "167.71.36.216/29"
      #         "167.71.36.224/27"
      #         "167.71.37.0/24"
      #         "167.71.38.0/23"
      #         "167.71.40.0/21"
      #         "167.71.48.0/20"
      #         "167.71.64.0/18"
      #         "167.71.128.0/17"
      #         "167.72.0.0/13"
      #         "167.80.0.0/12"
      #         "167.96.0.0/11"
      #         "167.128.0.0/9"
      #         "168.0.0.0/5"
      #         "176.0.0.0/4"
      #         "192.0.0.0/2"
      #       ];
      #       endpoint = "${domains.personal}:51820";
      #       persistentKeepalive = 25;
      #     }
      #   ];
      # };
      # wg_vpn = {
      #   ips = ["10.10.12.10/32"];
      #   privateKeyFile = ssh.ope.ope_wg_vps.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
      #       # allowedIPs = ["0.0.0.0/0" "::/0"];
      #       allowedIPs = ["0.0.0.0/0"];
      #       endpoint = "${domains.personal}:51822";
      #       persistentKeepalive = 25;
      #     }
      #   ];
      # };
      # wg_vps = {
      #   ips = ["10.10.10.10/32"];
      #   privateKeyFile = ssh.ope.ope_wg_vps.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
      #       # allowedIPs = ["10.10.10.1/32" "0.0.0.0/0"];
      #       # allowedIPs = [ "0.0.0.0/5" "8.0.0.0/7" "10.0.0.0/13" "10.8.0.0/15" "10.10.0.0/21" "10.10.8.0/23" "10.10.10.0/29" "10.10.10.1/32" "10.10.10.8/31" "10.10.10.11/32" "10.10.10.12/30" "10.10.10.16/28" "10.10.10.32/27" "10.10.10.64/26" "10.10.10.128/25" "10.10.11.0/24" "10.10.12.0/22" "10.10.16.0/20" "10.10.32.0/19" "10.10.64.0/18" "10.10.128.0/17" "10.11.0.0/16" "10.12.0.0/14" "10.16.0.0/12" "10.32.0.0/11" "10.64.0.0/10" "10.128.0.0/9" "11.0.0.0/8" "12.0.0.0/6" "16.0.0.0/4" "32.0.0.0/3" "64.0.0.0/2" "128.0.0.0/1" ];
      #       allowedIPs = ["10.10.10.1/32"];
      #       endpoint = "${domains.personal}:51820";
      #       persistentKeepalive = 25;
      #     }
      #   ];
      # };
    };
  };
}
