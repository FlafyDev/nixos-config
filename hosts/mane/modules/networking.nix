{ssh, utils, ...}: let
  inherit (utils) domains resolveHostname;
in {
  networking.enable = true;

  os.systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  os.systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks = {
      "50-ens3" = {
        matchConfig.Name = "ens3";
        networkConfig.DHCP = "yes";
      };
    };
  };

  # networking.notnft.namespaces.default.rules = with notnft.dsl; with payload; ruleset {
  #   filter = add table { family = f: f.inet; } {
  #     input = add chain { type = f: f.filter; hook = f: f.input; prio = 0; policy = f: f.accept; }
  #       [(is.eq tcp.dport 22) (mangle meta.mark 88)] # SSH
  #       [(is.eq udp.dport 51820) (mangle meta.mark 88)] # Wireguard
  #       ;

  #     prerouting = add chain { type = f: f.nat; hook = f: f.prerouting; prio = -100; policy = f: f.accept; }
  #       [(is.eq meta.iifname "ens3") (is.eq ip.daddr (resolveHostname domains.personal)) (is.eq tcp.dport (set [
  #         80 443 # Nginx on mera
  #         8000
  #       ])) (dnat.ip (resolveHostname "mera.wg_vps"))]
  #       [(is.eq meta.iifname "ens3") (is.eq ip.daddr (resolveHostname domains.personal)) (is.eq tcp.dport (set [
  #         8080 # Test on ope
  #       ])) (dnat.ip (resolveHostname "ope.wg_vps"))]
  #       ;

  #     postrouting = add chain { type = f: f.nat; hook = f: f.postrouting; prio = -100; policy = f: f.accept; }
  #       [(is.eq meta.iifname "wg_vps") (snat.ip (resolveHostname domains.personal))]
  #       ;
  #   };
  # };

  os.networking.nftables.tables.filter = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority 0; policy accept;
        meta nftrace set 1
        tcp dport 22 meta mark set 88  # SSH
        udp dport 51820 meta mark set 88  # Wireguard wg_vps
        udp dport 51821 meta mark set 88  # Wireguard wg_private
      }

      chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        meta nftrace set 1
        iifname "ens3" ip daddr ${resolveHostname domains.personal} tcp dport {
          80, 443,  # Nginx on mera
          8000
        } dnat ip to 10.10.10.11
        iifname "ens3" ip daddr ${resolveHostname domains.personal} tcp dport 8080 dnat ip to 10.10.10.10
        iifname "ens3" ip daddr ${resolveHostname domains.personal} udp dport 51822 dnat ip to 10.10.10.10
      }

      chain postrouting {
        type nat hook postrouting priority -100; policy accept;
        iifname "wg_vps" snat ip to ${resolveHostname domains.personal}
      }
    '';
  };

  os.networking.wireguard = {
    enable = true;
    interfaces = {
      wg_vps = {
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
      wg_private = {
        ips = [''${resolveHostname "mane.wg_private"}/24''];
        listenPort = 51821;
        privateKeyFile = ssh.mane.mane_wg_private.private;
        peers = [
          {
            publicKey = builtins.readFile ssh.ope.ope_wg_private.public;
            allowedIPs = [''${resolveHostname "ope.wg_private"}/32''];
          }
          {
            publicKey = builtins.readFile ssh.mera.mera_wg_private.public;
            allowedIPs = [''${resolveHostname "mera.wg_private"}/32''];
          }
          {
            publicKey = builtins.readFile ssh.glint.glint_wg_private.public;
            allowedIPs = [''${resolveHostname "glint.wg_private"}/32''];
          }
          # {
          #   publicKey = builtins.readFile ssh.mera.bara_wg_vps.public;
          #   allowedIPs = ["10.10.11.12/32"];
          # }
          # {
          #   publicKey = builtins.readFile ssh.mera.noro_wg_vps.public;
          #   allowedIPs = ["10.10.11.13/32"];
          # }
        ];
      };
    };
  };
}
