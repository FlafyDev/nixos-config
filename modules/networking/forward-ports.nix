{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkOption
    splitString
    last
    head
    types
    mkIf
    concatStringsSep
    hasInfix
    foldl'
    attrNames
    filterAttrs
    ;
  cfg = config.networking.forwardPorts;

  processPort = port:
    if hasInfix "," port
    then "{${port}}"
    else port;

  preroutingRules = concatStringsSep "\n" (
    foldl' (
      acc: ip:
        acc
        ++ (
          foldl' (
            acc: protocol:
              acc
              ++ (
                foldl' (
                  acc: port: let
                    portFrom = processPort (head (splitString "->" port));
                    portTo = processPort (last (splitString "->" port));
                    iifname = "iifname \"${cfg.${ip}.fromInterface}\"";
                  in
                    acc
                    ++ [
                      "${
                        if cfg.${ip}.fromInterface != null
                        then iifname
                        else ""
                      } ${protocol} dport ${portFrom} dnat ip to ${ip}:${portTo}"
                    ]
                ) []
                cfg.${ip}.${protocol}
              )
          ) [] ["tcp" "udp"]
        )
    ) [] (attrNames cfg)
  );

  postroutingRules = concatStringsSep "\n" (
    foldl' (
      acc: ip: acc ++ ["ip daddr ${ip} masquerade"]
    ) [] (attrNames (filterAttrs (_name: value: value.masquerade) cfg))
  );
in {
  options.networking.forwardPorts = mkOption {
    default = {};
    type = types.attrsOf (types.submodule {
      options = {
        masquerade = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Use masquerade.
          '';
        };
        fromInterface = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Which interface should be used for the forward ports.
          '';
        };
        tcp = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Which ports should be expose and accessable by the outside world.
            `networking.forwardPorts.<ip>.<tcp/udp> = [ ports ]`
          '';
        };
        udp = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Which ports should be expose and accessable by the outside world.
            `networking.forwardPorts.<ip>.<tcp/udp> = [ ports ]`
          '';
        };
      };
    });
  };

  config = mkIf config.networking.enable {
    os.networking.nftables = {
      enable = true;
      tables = {
        forward_ports = {
          name = "forward_ports";
          family = "inet";
          enable = true;
          content = ''
            chain prerouting {
                type nat hook prerouting priority 0 ;

                ${preroutingRules}
            }

            chain postrouting {
                type nat hook postrouting priority 100 ;

                ${postroutingRules}
            }
          '';
        };
      };
    };
  };
}
