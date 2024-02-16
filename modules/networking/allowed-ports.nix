{
  config,
  lib,
  utils,
  ...
}: let
  inherit (utils) resolveHostname;
  inherit
    (lib)
    mkOption
    types
    mkIf
    foldlAttrs
    concatStringsSep
    hasInfix
    elem
    ;
  cfg = config.networking.allowedPorts;

  # allowedPorts' =
  #   mapAttrs (
  #     _protocol: ports:
  #       mapAttrs (
  #         _port: addresses:
  #           if builtins.elem "0.0.0.0" addresses
  #           then true
  #           else addresses
  #       )
  #       ports
  #   )
  #   cfg;

  rules = concatStringsSep "\n" (foldlAttrs (acc: protocol: ports:
    acc
    ++ (
      foldlAttrs (
        acc: port: addresses: let
          # Should this even be allowed?
          port' =
            if hasInfix "," port
            then "{${port}}"
            else port;
        in
          acc
          ++ (
            if (elem "0.0.0.0" addresses) || (elem "*" addresses)
            then ["${protocol} dport ${port'} accept"]
            else if (elem port' config.networking.exposeLocalhost.${protocol})
            then map (address: "${protocol} dport ${port'} accept\nip daddr ${resolveHostname address} ${protocol} dport ${port'} accept") addresses
            else map (address: "ip saddr ${resolveHostname address} ${protocol} dport ${port'} accept\nip daddr ${resolveHostname address} ${protocol} dport ${port'} accept") addresses
          )
      ) []
      ports
    )) []
  cfg);
in {
  options.networking.allowedPorts = mkOption {
    type = with types; attrsOf (attrsOf (listOf str));
    default = {};
    description = ''
      Which ports should be allowed to be accessed by the outside world.
      `allowedPorts.<tcp/udp>.<port> = [ addresses ]`
    '';
  };

  config = mkIf config.networking.enable {
    os.networking.nftables = {
      enable = true;
      tables = {
        # test_tunnel = {
        #   name = "test_tunnel";
        #   family = "ip";
        #   enable = true;
        #   content = ''
        #     chain prerouting {
        #         type nat hook prerouting priority 0 ;
        #
        #         tcp dport 9091 dnat 127.0.0.1:9091
        #     }
        #
        #     chain postrouting {
        #         type nat hook postrouting priority 100 ;
        #     }
        #   '';
        # };
        # tcp dport 9091 counter accept
        #
        allow_ports = {
          name = "allow_ports";
          family = "inet";
          enable = true;
          content = ''
            chain input {
              type filter hook input priority 0;

              iif lo accept

              ct state established,related accept

              ip6 nexthdr icmpv6 accept
              ip protocol icmp accept

              ${rules}

              icmp type echo-request  accept comment "allow ping"

              icmpv6 type != { nd-redirect, 139 } accept comment "Accept all ICMPv6 messages except redirects and node information queries (type 139).  See RFC 4890, section 4.4."
              ip6 daddr fe80::/64 udp dport 546 accept comment "DHCPv6 client"

              drop
            }
            chain forward {
              type filter hook forward priority 0; policy drop;

              # forward WireGuard traffic, allowing it to access internet via WAN
              # iifname 10.10.12.10 oifname ens3 ct state new accept
              accept
            }
          '';
        };
      };
    };
    # We use nftables to allow ports, so we need to disable the Firewall port blocking.
    os.networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];
    };
  };
}
