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
                foldl' (acc: port: let
                  portFrom = processPort (head (splitString "->" port));
                  portTo = processPort (last (splitString "->" port));
                in
                  acc
                  ++ [
                    "${protocol} dport ${portFrom} dnat ip to ${ip}:${portTo}"
                  ]) []
                cfg.${ip}.${protocol}
              )
          ) [] ["tcp" "udp"]
        )
    ) []
  );

  postroutingRules = concatStringsSep "\n" (
    foldl' (
      acc: ip: acc ++ ["ip daddr ${ip} masquerade"]
    ) []
  );
in {
  options.networking.forwardPorts = mkOption {
    default = {};
    type = types.attrsOf (types.submodule {
      masquerade = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Use masquerade.
        '';
      };
      # allowPorts = mkOption {
      #   type = types.bool;
      #   default = true;
      #   description = ''
      #     Automatically allow the ports in `networking.allowedPorts`.
      #   '';
      # };
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
