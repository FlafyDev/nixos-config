{
  config,
  lib,
  resolveHostname,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    mkIf
    foldlAttrs
    mapAttrs
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

              drop
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
