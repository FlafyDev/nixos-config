# {
#   config,
#   lib,
#   ...
# }: let
#   inherit
#     (lib)
#     mkOption
#     splitString
#     last
#     head
#     types
#     mkIf
#     concatStringsSep
#     hasInfix
#     foldl'
#     ;
#   cfg = config.networking.exposeLocalhost;
#
#   processPort = port:
#     if hasInfix "," port
#     then "{${port}}"
#     else port;
#
#   rules = concatStringsSep "\n" (
#     foldl' (
#       acc: protocol:
#         acc
#         ++ (
#           foldl' (acc: port: let
#             portFrom = processPort (head (splitString "->" port));
#             portTo = processPort (last (splitString "->" port));
#           in
#             acc
#             ++ [
#               "${protocol} dport ${portFrom} dnat ip to 127.0.0.1:${portTo}"
#             ]) []
#           cfg.${protocol}
#         )
#     ) [] ["tcp" "udp"]
#   );
# in {
#   options.networking.exposeLocalhost = {
#     tcp = mkOption {
#       type = with types; listOf str;
#       default = [];
#       description = ''
#         Which ports should be expose and accessable by the outside world even though they run on localhost.
#         `exposeLocalhost.<tcp/udp> = [ ports ]`
#         Requires the port to be configured in allowedPorts.
#       '';
#     };
#     udp = mkOption {
#       type = with types; listOf str;
#       default = [];
#       description = ''
#         Which ports should be expose and accessable by the outside world even though they run on localhost.
#         `exposeLocalhost.<tcp/udp> = [ ports ]`
#         Requires the port to be configured in allowedPorts.
#       '';
#     };
#   };
#
#   config = mkIf config.networking.enable {
#     os.networking.nftables = {
#       enable = true;
#       tables = {
#         expose_localhost_tunnel = {
#           name = "expose_localhost_tunnel";
#           family = "inet";
#           enable = true;
#           content = ''
#             chain prerouting {
#                 type nat hook prerouting priority 0 ;
#
#                 ${rules}
#             }
#
#             chain postrouting {
#                 type nat hook postrouting priority 100 ;
#             }
#           '';
#         };
#       };
#     };
#   };
# }
{}
