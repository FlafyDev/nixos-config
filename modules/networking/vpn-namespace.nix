{
  config,
  configs,
  lib,
  utils,
  pkgs,
  ...
}: let
  inherit (utils) resolveHostname getHostname domains;
  inherit
    (lib)
    mkOption
    splitString
    length
    last
    filterAttrs
    types
    mkIf
    foldlAttrs
    foldl'
    attrValues
    ;
  cfg = config.networking.vpnNamespace;

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
                  fromInterface = "ens3";
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

  configThis = let
    lanCfgs = filterAttrs (_name: value: value.lanForward) cfg;
    tcpPorts = foldl' (acc: values: acc ++ values.ports.tcp) [] (attrValues cfg);
    udpPorts = foldl' (acc: values: acc ++ values.ports.udp) [] (attrValues cfg);
    tcpToLanPorts = map (port: last (splitString "->" port)) (foldl' (acc: values: acc ++ values.ports.tcp) [] (attrValues lanCfgs));
    udpToLanPorts = map (port: last (splitString "->" port)) (foldl' (acc: values: acc ++ values.ports.udp) [] (attrValues lanCfgs));

    containerConfigs =
      foldlAttrs (
        acc: namespace: values: (foldl' (acc: containerName:
            acc
            // {
              ${containerName} = {
                extraFlags = ["--network-namespace-path=/run/netns/${namespace}"] ++ (acc.${containerName}.extraFlags or []);
                bindMounts = {
                  "/etc/resolv.conf" = {
                    hostPath = toString (pkgs.writeText "resolv.conf" ''
                      nameserver 9.9.9.9
                      nameserver 1.1.1.1
                      nameserver 8.8.8.8
                    '');
                    isReadOnly = true;
                  };
                };
              };
            })
          acc
          values.containers)
      ) {}
      cfg;

    # chain postrouting {
    #     type nat hook postrouting priority 100; policy accept;
    #     oifname "enp14s0" ip saddr 10.10.15.11/24 masquerade
    # }
    #
    # chain forward {
    #     type filter hook forward priority 0; policy drop;
    #     iifname "enp14s0" oifname "vethhost0" accept
    #     oifname "enp14s0" iifname "vethhost0" accept
    # }

    # nftableConfigs =

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
                ${ip} netns exec vpn ip route add ${resolveHostname domains.personal} via 10.10.15.10 || true
              '';
              postSetup = ''
                # I don't know why without delay Wireguard doesn't work
                (sleep 1 && ${ip} netns exec ${namespace} ip link set lo up) || true &
              '';
            };
          }
      ) {}
      cfg;
  in {
    networking = {
      forwardPorts."10.10.15.11" = mkIf (length (attrValues lanCfgs) > 0) {
        tcp = tcpPorts;
        udp = udpPorts;
        masquerade =  true;
      };
      allowedPorts = { # Make this also only if it has lanCfgs?
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
    os = {
      environment.etc."netns/vpn/resolv.conf".text = ''
        nameserver 9.9.9.9
        nameserver 1.1.1.1
        nameserver 8.8.8.8
      '';

      networking.wireguard.interfaces = wireguardConfigs;

      networking.nftables = {
        enable = true;
        tables = {
          containers_local_internet_access = {
            name = "containers_local_internet_access";
            family = "ip";
            enable = false;

            content = ''
              chain postrouting {
                  type nat hook postrouting priority 100; policy accept;
                  ip saddr 10.10.15.11/24 masquerade
              }

              chain forward {
                  type filter hook forward priority 0; policy drop;
                  oifname "vethhost0" accept
                  iifname "vethhost0" accept
              }
            '';
          };
        };
      };
    };
  };
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
            containers = mkOption {
              type = types.listOf types.str;
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
          };
        }
      ));
    default = {};
    description = ''
      VPS forwarding settings.
    '';
  };

  config = mkIf config.networking.enable (lib.mkMerge [configThis configVpn]);
}
