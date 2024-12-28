{ssh, utils, notnft, ...}: let
  inherit (utils) domains resolveHostname;
in {
  networking.enable = true;

  networking.notnft.namespaces.default.rules = with notnft.dsl; with payload; ruleset {
    filter = add table { family = f: f.inet; } {
      input = add chain { type = f: f.filter; hook = f: f.input; prio = 0; policy = f: f.accept; }
        [(is.eq tcp.dport 22) (mangle meta.mark 88)] # SSH
        [(is.eq udp.dport 51820) (mangle meta.mark 88)] # Wireguard
        ;

      prerouting = add chain { type = f: f.nat; hook = f: f.prerouting; prio = -100; policy = f: f.accept; }
        [(is.eq meta.iifname "ens3") (is.eq ip.daddr (resolveHostname domains.personal)) (is.eq tcp.dport (set [
          80 443 # Nginx on mera
          8000
        ])) (dnat.ip (resolveHostname "mera.wg_vps"))]
        [(is.eq meta.iifname "ens3") (is.eq ip.daddr (resolveHostname domains.personal)) (is.eq tcp.dport (set [
          8080 # Test on ope
        ])) (dnat.ip (resolveHostname "ope.wg_vps"))]
        ;

      postrouting = add chain { type = f: f.nat; hook = f: f.postrouting; prio = -100; policy = f: f.accept; }
        [(is.eq meta.iifname "wg_vps") (snat.ip (resolveHostname domains.personal))]
        ;
    };
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
      # wg_private = {
      #   ips = ["10.10.11.1/24"];
      #   listenPort = 51821;
      #   privateKeyFile = ssh.mane.mane_wg_private.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.ope.ope_wg_private.public;
      #       allowedIPs = ["10.10.11.10/32"];
      #     }
      #     {
      #       publicKey = builtins.readFile ssh.mera.mera_wg_private.public;
      #       allowedIPs = ["10.10.11.11/32"];
      #     }
      #     # {
      #     #   publicKey = builtins.readFile ssh.mera.bara_wg_vps.public;
      #     #   allowedIPs = ["10.10.11.12/32"];
      #     # }
      #     # {
      #     #   publicKey = builtins.readFile ssh.mera.noro_wg_vps.public;
      #     #   allowedIPs = ["10.10.11.13/32"];
      #     # }
      #   ];
      # };
    };
  };
}

