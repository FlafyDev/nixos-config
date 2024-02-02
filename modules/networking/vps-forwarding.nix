{
  config,
  configs,
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
    mkMerge
    foldl'
    attrValues
    listToAttrs
    ;
  cfg = config.networking.vpsForwarding;

  portsToAllowVps = listToAttrs (map (
    protocol: {
      name = protocol;
      value = listToAttrs (
        map (port: {
          name = port;
          value = [cfg.${config.users.host}.settings.outgoingAddress];
        }) (
          foldl' (
            acc: config':
              acc
              ++ (config'.networking.vpsForwarding.${config.users.host}.${protocol} or [])
          ) []
          (attrValues configs)
        )
      );
    }
  ) ["tcp" "udp"]);

  portsToAllowThis = foldl' (acc: protocolsConfig: acc // protocolsConfig) {} (
    attrValues (
      mapAttrs (
        host: config': let
          address = "${config.users.host}.${configs.${host}.networking.vpsForwarding.${host}.settings.wireguardInterface}.flafy.me";
        in
          mapAttrs (_protocol: ports:
            listToAttrs (map (port: {
                name = port;
                value = [address];
              })
              ports))
          {inherit (config') udp tcp;}
      )
      cfg
    )
  );

  rules = concatStringsSep "\n" (
    foldlAttrs (
      acc: protocol: ports:
        acc
        ++ (
          foldlAttrs (
            acc: port: addresses: let
              port' =
                if hasInfix "," port
                then "{${port}}"
                else port;
            in
              acc
              ++ (
                map
                (address: "${protocol} dport ${port'} dnat to ${resolveHostname address}:${port'}")
                addresses
              )
          ) []
          ports
        )
    ) []
    portsToAllowVps
  );
in {
  options.networking.vpsForwarding = mkOption {
    type = with types;
      attrsOf (submodule (
        _: {
          options = {
            tcp = mkOption {
              type = with types; listOf str;
              default = [];
              description = ''
                List of TCP ports to forward.
              '';
            };
            udp = mkOption {
              type = with types; listOf str;
              default = [];
              description = ''
                List of UDP ports to forward.
              '';
            };
            settings = mkOption {
              type = with types;
                submodule (
                  _: {
                    options.wireguardInterface = mkOption {
                      type = types.str;
                      description = ''
                        Wireguard interface to use for VPS forwarding.
                      '';
                    };
                    options.outgoingAddress = mkOption {
                      type = types.str;
                      default = "0.0.0.0";
                      description = ''
                        Outgoing address for VPS forwarding.
                      '';
                    };
                  }
                );
              default = {};
              description = ''
                Settings to set by vps host.
              '';
            };
          };
        }
      ));
    default = {};
    description = ''
      VPS forwarding settings.
    '';
  };

  config = mkIf config.networking.enable (mkMerge [
    {
      os.networking.nftables = mkIf ((cfg.${config.users.host}.settings or {}) != {}) {
        enable = true;
        tables = {
          tunnel = {
            name = "tunnel";
            family = "ip";
            enable = true;

            # tcp dport 23-65535 dnat to 10.10.10.10:23-65535
            content = ''
              chain prerouting {
                  type nat hook prerouting priority 0 ;

                  ${rules}
              }

              chain postrouting {
                  type nat hook postrouting priority 100 ;
                  masquerade
              }
            '';
          };
        };
      };
      networking.allowedPorts = mkMerge [
        portsToAllowVps
        portsToAllowThis
      ];
    }
  ]);
}
