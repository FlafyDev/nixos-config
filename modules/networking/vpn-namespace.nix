{
  config,
  configs,
  lib,
  utils,
  pkgs,
  ...
}: let
  inherit (utils) resolveHostname getHostname;
  inherit
    (lib)
    mkOption
    splitString
    length
    filter
    last
    filterAttrs
    head
    attrsToList
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
  cfg = config.networking.vpnNamespace;

  processPort = port:
    if hasInfix "," port
    then "{${port}}"
    else port;

  # networking.forwardPorts.${utils.resolveHostname "ope.wg_vps"} = {
  #   tcp = ["5000"];
  #   masquerade = false;
  # };
  # networking.allowedPorts.tcp."5000" = ["0.0.0.0"];

  # configThis = [];
  # configVpn = [];

  configVpnInf =
    foldlAttrs (
      acc: host: cfgs:
        acc
        ++ (
          foldlAttrs (
            acc: _namespace: values:
              if values.vpnHost == host
              then []
              else
                (
                  acc
                  ++ [
                    {
                      networking.forwardPorts.${utils.resolveHostname "${host}.${values.vpnWgInterface}"}.masquerade = false;
                    }
                  ]
                  ++ (foldl' (acc: port: let
                    portTo = last (splitString "->" port);
                  in
                    acc
                    ++ [
                      {
                        # networking.forwardPorts.${utils.resolveHostname "${host}.${values.vpnWgInterface}"}.tcp = [port];
                        # networking.allowedPorts.tcp.${portTo} = ["0.0.0.0"];
                      }
                    ]) []
                  values.ports.tcp)
                  ++ (foldl' (acc: port: let
                    portTo = last (splitString "->" port);
                  in
                    acc
                    ++ [
                      {
                        # networking.forwardPorts.${utils.resolveHostname "${host}.${values.vpnWgInterface}"}.udp = [port];
                        # networking.allowedPorts.udp.${portTo} = ["0.0.0.0"];
                      }
                    ]) []
                  values.ports.udp)
                )
          ) []
          cfgs.networking.vpnNamespace
        )
    ) []
    configs;

  configVpn = let
    applicableConfigs =
      foldlAttrs (
        acc: host: hostConfig: let
          namespaceConfigs =
            filterAttrs (
              _host: hostConfig: hostConfig.vpnHost == config.users.host
            )
            hostConfig.networking.vpnNamespace;
        in
          acc
          // (
            if namespaceConfigs != {}
            then {
              ${host} = namespaceConfigs;
            }
            else {}
          )
      ) {}
      configs;
    applicableConfigsFlat =
      foldlAttrs (
        acc: host: hostConfig:
          acc
          ++ (foldlAttrs (
              acc: namespace: values:
                acc
                ++ [
                  (
                    values
                    // {
                      inherit namespace host;
                    }
                  )
                ]
            ) []
            hostConfig)
      ) []
      applicableConfigs;

    # appliciableConfigs = filterAttrs (_host: hostConfig: hostConfig.vpnHost == config.users.host) configs;

    # tcpToPorts = map (port: last (splitString "->" port)) (
    #   foldl' (
    #     acc: values:
    #       acc ++ values.ports.tcp
    #   )
    #   []
    #   (filter (attrValues (map (_host: hostConfig: hostConfig) configs).networking.vpnNamespace))
    # );
    tcpToPorts = map (port: last (splitString "->" port)) (foldl' (acc: values: acc ++ values.ports.tcp) [] applicableConfigsFlat);
    udpToPorts = map (port: last (splitString "->" port)) (foldl' (acc: values: acc ++ values.ports.udp) [] applicableConfigsFlat);

    forwardPortsConfig =
      foldlAttrs (
        acc: host: hostConfig:
          foldlAttrs (acc: _namespace: values: let
            ip = utils.getHostname "${host}.${values.vpnWgInterface}";
          in
            acc
            // (
              if values.vpnHost == config.users.host
              then {
                ${ip} = {
                  tcp = values.ports.tcp ++ (acc.${ip}.tcp or []);
                  udp = values.ports.udp ++ (acc.${ip}.udp or []);
                  masquerade = false;
                };
              }
              else {}
            ))
          acc
          hostConfig
      ) {}
      applicableConfigs;
  in {
    networking = {
      forwardPorts = forwardPortsConfig;
      allowedPorts = {
        tcp = foldl' (acc: port:
          acc
          // {
            ${port} = ["0.0.0.0"];
          }) {}
        tcpToPorts;
        udp = foldl' (acc: port:
          acc
          // {
            ${port} = ["0.0.0.0"];
          }) {}
        udpToPorts;
      };
    };
  };

  # configThisInf = lib.traceVal (
  #   foldlAttrs (
  #     acc: namespace: values:
  #       acc
  #       //
  #       # networking =
  #       #   acc
  #       {
  #         containers.${values.container} = {
  #           extraFlags = ["--network-namespace-path=/run/netns/${namespace}"];
  #         };
  #
  #         networking.forwardPorts."10.10.15.11".masquerade = mkIf values.lanForward true;
  #
  #         os.networking.wireguard.interfaces.${values.vpnWgInterface} = let
  #           ip = "${pkgs.iproute2}/bin/ip";
  #         in {
  #           interfaceNamespace = namespace;
  #           socketNamespace = "init";
  #           preSetup = ''
  #             ${ip} netns add ${namespace} || true
  #
  #             ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
  #             ${ip} link set vethvpn0 netns ${namespace} || true
  #             ${ip} addr add 10.10.15.10/24 dev vethhost0 || true
  #             ${ip} netns exec ${namespace} ip addr add 10.10.15.11/24 dev vethvpn0 || true
  #             ${ip} link set vethhost0 up || true
  #             ${ip} netns exec ${namespace} ip link set vethvpn0 up || true
  #           '';
  #           networking.forwardPorts."10.10.15.11".tcp = values.ports.tcp ++ acc.networking.forwardPorts."10.10.15.11".tcp;
  #           networking.forwardPorts."10.10.15.11".udp = values.ports.udp ++ acc.networking.forwardPorts."10.10.15.11".udp;
  #         };
  #       }
  #       // (foldl' (acc: port: let
  #         portTo = last (splitString "->" port);
  #       in
  #         acc
  #         ++ [
  #           {
  #             networking.allowedPorts.tcp.${portTo} = mkIf values.lanForward [(resolveHostname "ope.lan1")];
  #           }
  #         ]) []
  #       values.ports.tcp)
  #       // (foldl' (acc: port: let
  #         portTo = last (splitString "->" port);
  #       in
  #         acc
  #         ++ [
  #           {
  #             networking.allowedPorts.udp.${portTo} = mkIf values.lanForward [(resolveHostname "ope.lan1")];
  #           }
  #         ]) []
  #       values.ports.udp)
  #   ) {}
  #   cfg
  # );

  configThis = let
    lanCfgs = filterAttrs (_name: value: value.lanForward) cfg;
    tcpPorts = foldl' (acc: values: acc ++ values.ports.tcp) [] (attrValues cfg);
    udpPorts = foldl' (acc: values: acc ++ values.ports.udp) [] (attrValues cfg);
    tcpToLanPorts = map (port: last (splitString "->" port)) (foldl' (acc: values: acc ++ values.ports.tcp) [] (attrValues lanCfgs));
    udpToLanPorts = map (port: last (splitString "->" port)) (foldl' (acc: values: acc ++ values.ports.udp) [] (attrValues lanCfgs));

    containerConfigs =
      foldlAttrs (
        acc: namespace: values:
          acc
          // {
            ${values.container} = {
              extraFlags = ["--network-namespace-path=/run/netns/${namespace}"];
            };
          }
      ) {}
      cfg;

    wireguardConfigs =
      foldlAttrs (
        acc: namespace: values:
          acc
          // {
            ${values.vpnWgInterface} = let
              ip = "${pkgs.iproute2}/bin/ip";
            in {
              interfaceNamespace = namespace;
              socketNamespace = "init";
              preSetup = ''
                ${ip} netns add ${namespace} || true

                ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
                ${ip} link set vethvpn0 netns ${namespace} || true
                ${ip} addr add 10.10.15.10/24 dev vethhost0 || true
                ${ip} netns exec ${namespace} ip addr add 10.10.15.11/24 dev vethvpn0 || true
                ${ip} link set vethhost0 up || true
                ${ip} netns exec ${namespace} ip link set vethvpn0 up || true
              '';
            };
          }
      ) {}
      cfg;
  in {
    networking = {
      forwardPorts."10.10.15.11" = {
        tcp = tcpPorts;
        udp = udpPorts;
        masquerade = mkIf (length (attrValues lanCfgs) > 0) true;
      };
      allowedPorts = {
        tcp = foldl' (acc: port:
          acc
          // {
            ${port} = [(getHostname "${config.users.host}.lan1")];
          }) {}
        tcpToLanPorts;
        udp = foldl' (acc: port:
          acc
          // {
            ${port} = [(getHostname "${config.users.host}.lan1")];
          }) {}
        udpToLanPorts;
      };
    };

    containers = containerConfigs;

    os.networking.wireguard.interfaces = wireguardConfigs;
  };
  # configThis = lib.mapAttrsToList (name: value: value) (lib.traceVal config.networking.vpnNamespace );
  # portsToAllowVps = listToAttrs (map (
  #   protocol: {
  #     name = protocol;
  #     value = listToAttrs (
  #       map (port: let
  #         portTo = processPort (last (splitString "->" port));
  #       in {
  #         name = portTo;
  #         value = [cfg.${config.users.host}.settings.outgoingAddress];
  #       }) (
  #         foldl' (
  #           acc: config':
  #             acc
  #             ++ (config'.networking.vpsForwarding.${config.users.host}.${protocol} or [])
  #         ) []
  #         (attrValues configs)
  #       )
  #     );
  #   }
  # ) ["tcp" "udp"]);
  # Forwarding rules
  # rules = concatStringsSep "\n" (
  #   foldl' (
  #     acc: protocol:
  #       acc
  #       ++ (
  #         foldlAttrs (
  #           acc: host: config': let
  #             ports = config'.networking.vpsForwarding.${config.users.host}.${protocol} or [];
  #             address = "${host}.${getHostname cfg.${config.users.host}.settings.wireguardInterface}";
  #           in
  #             acc
  #             ++ (foldl' (acc: port: let
  #               portFrom = processPort (head (splitString "->" port));
  #               portTo = processPort (last (splitString "->" port));
  #             in
  #               acc
  #               ++ [
  #                 "${protocol} dport ${portTo} dnat ip to ${resolveHostname address}:${portFrom}"
  #               ]) []
  #             ports)
  #         ) []
  #         configs
  #       )
  #   ) [] ["tcp" "udp"]
  # );
  # portsToAllowThis = foldl' (acc: protocolsConfig: acc // protocolsConfig) {} (
  #   attrValues (
  #     mapAttrs (
  #       host: config': let
  #         address = "${config.users.host}.${getHostname configs.${host}.networking.vpsForwarding.${host}.settings.wireguardInterface}";
  #       in
  #         mapAttrs (_protocol: ports:
  #           listToAttrs (map (port: let
  #               portFrom = processPort (head (splitString "->" port));
  #             in {
  #               name = portFrom;
  #               value = [address];
  #             })
  #             ports))
  #         {inherit (config') udp tcp;}
  #     )
  #     cfg
  #   )
  # );
in {
  options.networking.vpnNamespace = mkOption {
    type = with types;
      attrsOf (submodule (
        _: {
          options = {
            ports = {
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
            };
            container = mkOption {
              type = types.str;
              description = ''
                Container to assign the VPN namespace to.
              '';
            };
            vpnHost = mkOption {
              type = types.str;
              description = ''
                Host to act as the VPN for the namespace.
              '';
            };
            vpnWgInterface = mkOption {
              type = types.str;
              description = ''
                Wireguard interface with the vpnHost.
              '';
            };
            lanForward = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether to forward ports to LAN traffic.
              '';
            };
            # settings = mkOption {
            #   type = with types;
            #     submodule (
            #       _: {
            #         options = {
            #           wireguardInterface = mkOption {
            #             type = types.str;
            #             description = ''
            #               Wireguard interface to use for VPS forwarding.
            #             '';
            #           };
            #           outgoingAddress = mkOption {
            #             type = types.str;
            #             default = "0.0.0.0";
            #             description = ''
            #               Outgoing address for VPS forwarding.
            #             '';
            #           };
            #           excludeInterfaces = mkOption {
            #             type = with types; listOf str;
            #             default = [];
            #             description = ''
            #               Interfaces to exclude from prerouting. Still not sure what that means exactly lol.
            #             '';
            #           };
            #         };
            #       }
            #     );
            #   default = {};
            #   description = ''
            #     Settings to set by vps host.
            #   '';
            # };
          };
        }
      ));
    default = {};
    description = ''
      VPS forwarding settings.
    '';
  };

  # config = {
  #   # networking.enable = builtins.trace ( lib.mapAttrsToList (name: value: value) (config.networking.vpnNamespace ) ) ( mkIf (config.networking.vpnNamespace.vpn.container == "maneVpn") true );
  # };

  config = mkIf config.networking.enable (configThis // configVpn);

  # config = mkIf config.networking.enable (mkMerge (
  #   # configThis
  #   # ++ configVpn
  #   [
  #     (configThis // {
  #       # os.networking.nftables = mkIf ((cfg.${config.users.host}.settings or {}) != {}) {
  #       #   enable = true;
  #       #   tables = {
  #       #     tunnel = {
  #       #       name = "tunnel";
  #       #       family = "inet";
  #       #       enable = true;
  #       #
  #       #       content = ''
  #       #         chain prerouting {
  #       #             type nat hook prerouting priority 0 ;
  #       #
  #       #             iifname {${concatStringsSep "," cfg.${config.users.host}.settings.excludeInterfaces}} accept;
  #       #
  #       #             ## TEMP22
  #       #             tcp dport 5000 dnat ip to 10.10.10.10:5000
  #       #
  #       #             ${rules}
  #       #         }
  #       #
  #       #         chain postrouting {
  #       #             type nat hook postrouting priority 100 ;
  #       #             masquerade
  #       #             # oifname ens3 ip saddr 10.10.12.1/24 masquerade
  #       #         }
  #       #       '';
  #       #     };
  #       #   };
  #       # };
  #       # networking.allowedPorts = mkMerge [
  #       #   portsToAllowVps
  #       #   portsToAllowThis
  #       # ];
  #     })
  #   ]
  # ));
}
