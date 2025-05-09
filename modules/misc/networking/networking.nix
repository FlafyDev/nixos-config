{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption;
  cfg = config.networking;
in {
  options.networking = {
    enable = mkEnableOption "networking";
    wireguard = mkEnableOption "wireguard";
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

    os.systemd.network.enable = true;
    os.systemd.services.systemd-rfkill.enable = false;
    os.networking = {
      nftables.enable = true;
      firewall.enable = false;
      useNetworkd = true;
      networkmanager = {
        enable = false;
      };
      useDHCP = false;
    };

    os.networking.wireguard.enable = mkIf cfg.wireguard true;
    os.networking.wireguard.useNetworkd = true;
    os.boot.kernelModules = mkIf cfg.wireguard ["wireguard"];
    os.environment.systemPackages = mkIf cfg.wireguard [pkgs.wireguard-tools];

    os.boot.kernel.sysctl = {
      "net.ipv4.conf.all.route_localnet" = 1;
      "net.ipv4.ip_forward" = 1;
    };
    os.networking.nftables.tables.default-filter = {
      family = "inet";
      content = ''
        chain input {
          type filter hook input priority 100; policy accept;

          # accept any traffic marked as accepted(which is mark 88)
          meta mark 88 accept

          # accept any localhost traffic
          iifname lo accept

          # accept traffic originated from us
          ct state {established, related} accept

          # ICMP
          # routers may also want: mld-listener-query, nd-router-solicit
          ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
          ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept

          # allow "ping"
          ip6 nexthdr icmpv6 icmpv6 type echo-request accept
          ip protocol icmp icmp type echo-request accept

          accept

          # count and drop any other traffic
          counter drop
        }

        # Allow all outgoing connections.
        chain output {
          type filter hook output priority 0; policy accept;
        }

        chain forward {
          type filter hook forward priority 100; policy accept;

          # accept any traffic marked as accepted(which is mark 89)
          meta mark 89 accept

          # TODO
          accept

          # count and drop any other traffic
          counter drop
        }
      '';
    };
  };
}
