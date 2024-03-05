{}
# {
#   config,
#   configs,
#   lib,
#   utils,
#   ...
# }: let
#   inherit (utils) resolveHostname getHostname;
#   inherit
#     (lib)
#     mkOption
#     splitString
#     last
#     head
#     types
#     mkIf
#     foldlAttrs
#     mapAttrs
#     concatStringsSep
#     hasInfix
#     mkMerge
#     foldl'
#     attrValues
#     listToAttrs
#     ;
#   cfg = config.networking.vpsForwarding;
#
#   processPort = port:
#     if hasInfix "," port
#     then "{${port}}"
#     else port;
#
#   portsToAllowVps = listToAttrs (map (
#     protocol: {
#       name = protocol;
#       value = listToAttrs (
#         map (port: let
#           portTo = processPort (last (splitString "->" port));
#         in {
#           name = portTo;
#           value = [cfg.${config.users.host}.settings.outgoingAddress];
#         }) (
#           foldl' (
#             acc: config':
#               acc
#               ++ (config'.networking.vpsForwarding.${config.users.host}.${protocol} or [])
#           ) []
#           (attrValues configs)
#         )
#       );
#     }
#   ) ["tcp" "udp"]);
#
#   # Forwarding rules
#   rules = concatStringsSep "\n" (
#     foldl' (
#       acc: protocol:
#         acc
#         ++ (
#           foldlAttrs (
#             acc: host: config': let
#               ports = config'.networking.vpsForwarding.${config.users.host}.${protocol} or [];
#               address = "${host}.${getHostname cfg.${config.users.host}.settings.wireguardInterface}";
#             in
#               acc
#               ++ (foldl' (acc: port: let
#                 portFrom = processPort (head (splitString "->" port));
#                 portTo = processPort (last (splitString "->" port));
#               in
#                 acc
#                 ++ [
#                   "${protocol} dport ${portTo} dnat ip to ${resolveHostname address}:${portFrom}"
#                 ]) []
#               ports)
#           ) []
#           configs
#         )
#     ) [] ["tcp" "udp"]
#   );
#
#   portsToAllowThis = foldl' (acc: protocolsConfig: acc // protocolsConfig) {} (
#     attrValues (
#       mapAttrs (
#         host: config': let
#           address = "${config.users.host}.${getHostname configs.${host}.networking.vpsForwarding.${host}.settings.wireguardInterface}";
#         in
#           mapAttrs (_protocol: ports:
#             listToAttrs (map (port: let
#                 portFrom = processPort (head (splitString "->" port));
#               in {
#                 name = portFrom;
#                 value = [address];
#               })
#               ports))
#           {inherit (config') udp tcp;}
#       )
#       cfg
#     )
#   );
# in {
#   options.networking.vpsForwarding = mkOption {
#     type = with types;
#       attrsOf (submodule (
#         _: {
#           options = {
#             tcp = mkOption {
#               type = with types; listOf str;
#               default = [];
#               description = ''
#                 List of TCP ports to forward.
#               '';
#             };
#             udp = mkOption {
#               type = with types; listOf str;
#               default = [];
#               description = ''
#                 List of UDP ports to forward.
#               '';
#             };
#             settings = mkOption {
#               type = with types;
#                 submodule (
#                   _: {
#                     options = {
#                       wireguardInterface = mkOption {
#                         type = types.str;
#                         description = ''
#                           Wireguard interface to use for VPS forwarding.
#                         '';
#                       };
#                       outgoingAddress = mkOption {
#                         type = types.str;
#                         default = "0.0.0.0";
#                         description = ''
#                           Outgoing address for VPS forwarding.
#                         '';
#                       };
#                       excludeInterfaces = mkOption {
#                         type = with types; listOf str;
#                         default = [];
#                         description = ''
#                           Interfaces to exclude from prerouting. Still not sure what that means exactly lol.
#                         '';
#                       };
#                     };
#                   }
#                 );
#               default = {};
#               description = ''
#                 Settings to set by vps host.
#               '';
#             };
#           };
#         }
#       ));
#     default = {};
#     description = ''
#       VPS forwarding settings.
#     '';
#   };
#
#   config = mkIf config.networking.enable (mkMerge [
#     {
#       os.networking.nftables = mkIf ((cfg.${config.users.host}.settings or {}) != {}) {
#         enable = true;
#         tables = {
#           tunnel = {
#             name = "tunnel";
#             family = "inet";
#             enable = true;
#
#             content = ''
#               chain prerouting {
#                   type nat hook prerouting priority 0 ;
#
#                   iifname {${concatStringsSep "," cfg.${config.users.host}.settings.excludeInterfaces}} accept;
#
#                   ${rules}
#               }
#
#               chain postrouting {
#                   type nat hook postrouting priority 100 ;
#                   masquerade
#                   #oifname ens3 ip saddr 10.10.12.1/24 masquerade
#               }
#             '';
#           };
#         };
#       };
#       networking.allowedPorts = mkMerge [
#         portsToAllowVps
#         portsToAllowThis
#       ];
#     }
#   ]);
# }
#
