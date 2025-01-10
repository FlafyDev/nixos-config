{
  lib,
  config,
  notnft,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption;
  cfg = config.networking;
in {
  options.networking = {
    enable = mkEnableOption "networking";
    domains = mkOption {
      type = with lib.types; attrsOf str;
      default = {
        personal = "flafy.dev";
      };
      description = "Domains";
    };
  };

  config = mkIf cfg.enable {
    utils.extraUtils = {
      inherit (cfg) domains;
    };
    os.networking = {
      nftables.enable = false;
      firewall.enable = false;
    };
    os.boot.kernel.sysctl = {
      "net.ipv4.conf.all.route_localnet" = 1;
      "net.ipv4.ip_forward" = 1;
      # "net.ipv4.conf.all.proxy_arp" = 1;
    };
    networking.notnft.namespaces.default.rules = with notnft.dsl; with payload; ruleset {
      default-filter = add table { family = f: f.inet; } {
        input = add chain { type = f: f.filter; hook = f: f.input; prio = 100; policy = f: f.accept; }
          # Mark 88 means it was accepted by another hook
          [(is.eq meta.mark 88) accept]

          # accept any localhost traffic
          [(is.eq meta.iifname "lo") accept]

          # accept traffic originated from us
          [(vmap ct.state { established = accept; related = accept; })]

          # ICMP
          # routers may also want: mld-listener-query, nd-router-solicit
          [(is.eq ip6.nexthdr (f: f.ipv6-icmp)) (is.eq icmpv6.type (f: with f; set [ destination-unreachable packet-too-big time-exceeded parameter-problem nd-router-advert nd-neighbor-solicit nd-neighbor-advert ])) accept]
          [(is.eq ip.protocol (f: f.icmp)) (is.eq icmp.type (f: with f; set [ destination-unreachable router-advertisement time-exceeded parameter-problem ])) accept]

          # allow "ping"
          [(is.eq ip6.nexthdr (f: f.ipv6-icmp)) (is.eq icmpv6.type (f: f.echo-request)) accept]
          [(is.eq ip.protocol (f: f.icmp)) (is.eq icmp.type (f: f.echo-request)) accept]

          # count and drop any other traffic
          [(counter {packets = 0; bytes = 0;}) drop];

        output = add chain { type = f: f.filter; hook = f: f.output; prio = 0; policy = f: f.accept; }
          [accept];

        forward = add chain { type = f: f.filter; hook = f: f.forward; prio = 0; policy = f: f.accept; }
          [accept];
      };
    };
  };
}
