{
  pkgs,
  lib,
  config,
  utils,
  notnft,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (utils) resolveHostname domains;
  cfg = config.networking.vpnClient;
in {
  options.networking = {
    vpnClient = {
      enable = mkEnableOption "vpnClient";
      forwardPortsOutOfNS = mkOption {
        type = with lib.types; listOf notnft.types.expression;
        default = [];
        description = "Requests with these interfaces will be forwarded from the VPN to here but not to the interface";
      };
      namespace = mkOption {
        type = with lib.types; str;
        default = "vpn";
        description = "Namespace";
      };
    };
  };

  config = mkIf (config.networking.enable && cfg.enable) {
    os.systemd.services = {
      wireguard-wg_vps = {
        wantedBy = ["network-online.target" "multi-user.target"];
      };
      notnftables-vpn = {
        after = ["network-online.target" "notnftables-vpn.service"];
        before = ["wireguard-wg_vps.service"];
        wantedBy = ["network-online.target" "multi-user.target"];
        requiredBy = ["wireguard-wg_vps.service"];
      };
      create-rules = {
        description = "Create rules";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        before = ["wireguard-wg_vps.service" "notnftables-vpn.service"];
        wantedBy = ["network-online.target" "multi-user.target"];
        requiredBy = ["notnftables-vpn.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = let
            ip = "${pkgs.iproute2}/bin/ip";
            inherit (cfg) namespace;
          in pkgs.writeShellScript "create-rules" ''
            ${ip} netns add ${namespace} || true

            ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
            ${ip} link set vethvpn0 netns ${namespace} || true
            ${ip} addr add 10.10.15.10/24 dev vethhost0 || true
            ${ip} netns exec ${namespace} ${ip} addr add 10.10.15.11/24 dev vethvpn0 || true
            ${ip} link set vethhost0 up || true
            ${ip} netns exec ${namespace} ${ip} link set vethvpn0 up || true
            ${ip} netns exec ${namespace} ${ip} route add ${resolveHostname domains.personal} via 10.10.15.10 || true

            ${ip} rule add from 10.10.15.10 table 3 prio 1 || true
            ${ip} route add default via 10.10.15.11 dev vethhost0 table 3 || true

            ${ip} netns exec ${namespace} ${ip} rule add fwmark 123 table 2 || true
            ${ip} netns exec ${namespace} ${ip} route add default via 10.10.15.11 table 2 || true

            ${ip} netns exec ${namespace} ${ip} link set lo up || true
          '';
        };
      };
    };

    networking.notnft.namespaces = with notnft.dsl; with payload; {
      default.rules = ruleset {
        vpn-allow-vethhost0 = add table { family = f: f.inet; } {
          input = add chain { type = f: f.filter; hook = f: f.input; prio = 0; policy = f: f.accept; }
            # accept if incoming from container interface
            [(is.eq meta.iifname "vethhost0") (mangle meta.mark 88)]
            ;
        };
      };
      vpn.rules = ruleset {
        routing = add table { family = f: f.inet; } {
          input = add chain { type = f: f.filter; hook = f: f.input; prio = 0; policy = f: f.accept; } 
            [accept]
            ;

          output = add chain { type = f: f.filter; hook = f: f.output; prio = 0; policy = f: f.accept; }
            [accept]
            ;

          forward = add chain { type = f: f.filter; hook = f: f.forward; prio = 0; policy = f: f.accept; }
            [accept]
            ;

          prerouting = add chain { type = f: f.nat; hook = f: f.prerouting; prio = -100; policy = f: f.accept; }
            [(is.eq meta.iifname "wg_vps") (is.eq tcp.dport (set cfg.forwardPortsOutOfNS)) (mangle meta.mark 123) (dnat.ip "10.10.15.10")]
            ;

          postrouting = add chain { type = f: f.nat; hook = f: f.postrouting; prio = -100; policy = f: f.accept; }
            ;
        };
      };
    };
  };
}
