{ pkgs, lib, config, utils, ... }:
let
  inherit (lib)
    mkEnableOption mkIf mkOption optionals mapAttrs' types filterAttrs mkMerge
    toIntBase10;
  inherit (utils) resolveHostname;
  cfg = config.setupGroups;
in {
  options = {
    setupGroups = {
      enable = mkEnableOption "setupGroups";
      homeInterface = mkOption {
        type = types.str;
        description = "Name of the home interface";
      };
      homeSubnet = mkOption {
        type = types.str;
        description = "Subnet of the home network";
      };
      vpnInterface = mkOption {
        type = types.str;
        description = "Name of the VPN interface";
      };
      vpnSubnet = mkOption {
        type = types.str;
        description = "Subnet of the VPN network";
      };
      forceHomeIPs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description =
          "IPs that should always go through the home interface even if the gateway is the VPN";
      };
      groups = mkOption {
        default = {};
        type = types.attrsOf (types.submodule ({ config, ... }: {
          options = {
            gateway = mkOption {
              type = with types; nullOr (enum [ "vpn" "home" ]);
              default = null;
              description = "Through which gateway packets would be sent";
            };
            interface = mkOption {
              type = with types; str;
              description = "Interface to connect to the group";
            };
            helpers = {
              microvm = mkOption {
                type = with types; nullOr str;
                default = null;
                description = "MicroVM name to connect to the group";
              };
              namespace = mkOption {
                type = with types; nullOr str;
                default = null;
                description = "Namespace name to connect to the group";
              };
              # bridge = mkOption {
              #   type = with types; nullOr str;
              #   default = null;
              #   description = "Bridge to connect to the group";
              # };
            };
            inputRules = mkOption {
              type = with types; functionTo str;
              default = _: "";
              example = ''
                iifname vm0 meta mark set 88
              '';
              description = "Input rules";
            };
            forwardRules = mkOption {
              type = with types; functionTo str;
              default = _: "";
              example = ''
                # Accept all outgoing/incoming packets to the VM
                oifname vm0 meta mark set 89
                iifname vm0 meta mark set 89
              '';
              description = "Forward rules";
            };
            extraPrerouting = mkOption {
              type = with types; functionTo str;
              default = _: "";
              example = ''
                # Redirect to vm0 all tcp 80 packets the host receives
                iifname != "vm0" tcp dport 80 dnat ip to 10.10.15.2
              '';
              description = "Extra prerouting";
            };
            extraPostrouting = mkOption {
              type = with types; functionTo str;
              default = _: "";
              example = ''
                # give access to mera port 5000
                iifname vm0 ip daddr 10.0.0.41 tcp dport { 5000 } snat to 10.0.0.42
              '';
              description = "Extra postrouting";
            };
          };
          config = mkMerge [
            {
              interface =
                mkIf (config.helpers.microvm != null) config.helpers.microvm;
            }
            {
              interface = mkIf (config.helpers.namespace != null)
                "${config.helpers.namespace}-host";
            }
            {
              # interface = mkIf (config.helpers.bridge != null)
              #   (config.helpers.bridge + "-host");
            }
          ];
        }));
      };
    };
  };

  config = mkIf (config.networking.enable && cfg.enable) {
    os.systemd.network.networks = (mapAttrs' (gpID: gpCfg:
      let ips = utils.gpIP (toIntBase10 gpID);
      in {
        name = "10-gp${gpID}";
        value = {
          matchConfig.Name = gpCfg.interface;
          networkConfig = {
            Address = "${ips.host}/30";
            IPv6AcceptRA = false;
            DHCPServer = "yes";
            DHCP = "no";
          };
          routes = [{
            Destination = "${ips.guest}/30";
            Table = 2;
            Scope = "link";
          }];
          routingPolicyRules = optionals (gpCfg.gateway == "vpn") [{
            Family = "ipv4";
            IncomingInterface = gpCfg.interface;
            Table = 2;
          }];
        };
      }) cfg.groups) // {
        "50-${cfg.homeInterface}" = {
          matchConfig.Name = cfg.homeInterface;
          routes = [
            # Don't route traffic destined to home network through the vpn.
            {
              Destination = cfg.homeSubnet;
              Table = 2;
              Scope = "link";
            }
          ] ++ (map (ip: {
            # Route traffic to these IPs through the home interface. Even if the gateway is the VPN.
            Destination = ip;
            Table = 2;
            Gateway = "_dhcp4";
          }) cfg.forceHomeIPs);
        };
        "50-${cfg.vpnInterface}" = {
          matchConfig.Name = cfg.vpnInterface;
          routes = [
            # Default route for table 2
            {
              Destination = "0.0.0.0/0";
              Table = 2;
              Scope = "link";
            }
            # Default route for table 3
            {
              Destination = "0.0.0.0/0";
              Table = 3;
              Scope = "link";
            }
          ];
          routingPolicyRules = [
            # Make sure all traffic that comes from vpnSubnet goes to table 3 (to get oif cfg.vpnInterface)
            {
              Family = "ipv4";
              From = cfg.vpnSubnet;
              Table = 3;
            }
          ];
        };
      } // (mapAttrs' (gpID: gpCfg: {
        name = "10-${gpCfg.helpers.namespace}-ns";
        value = {
          matchConfig.Name = "${gpCfg.helpers.namespace}-ns";
          networkConfig = {
            DHCP = true;
          };
        };
      }) (filterAttrs (_: gpCfg: gpCfg.helpers.namespace != null) cfg.groups));

    os.systemd.network.netdevs = mapAttrs' (gpID: gpCfg: {
      name = "10-${gpCfg.interface}";
      value = {
        netdevConfig = {
          Name = gpCfg.interface;
          Kind = "veth";
        };
        peerConfig = { Name = "${gpCfg.helpers.namespace}-ns"; };
      };
    }) (filterAttrs (_: gpCfg: gpCfg.helpers.namespace != null) cfg.groups);

    os.systemd.services = mapAttrs' (gpID: gpCfg: let
      ips = utils.gpIP (toIntBase10 gpID);
    in {
      name = "${gpCfg.helpers.namespace}-creator";
      value = {
        description = "Managed Network Namespace";
        after = [ "systemd-networkd.service" ];
        wants = [ "systemd-networkd.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          # Create the namespace
          ${pkgs.iproute2}/bin/ip netns add ${gpCfg.helpers.namespace} || true

          ${pkgs.iproute2}/bin/ip link set ${gpCfg.helpers.namespace}-ns netns ${gpCfg.helpers.namespace} || true

          # Reconfigure it imperatively because configuration for some reason isn't saved after moving it... 
          ${pkgs.iproute2}/bin/ip netns exec ${gpCfg.helpers.namespace} ${pkgs.iproute2}/bin/ip addr add ${ips.guest}/30 dev ${gpCfg.helpers.namespace}-ns || true

          # A veth device will be stuck on configuring unless its peer exists and is up.
          # Needs to be UP-ed before adding the gateway route.
          ${pkgs.iproute2}/bin/ip netns exec ${gpCfg.helpers.namespace} ${pkgs.iproute2}/bin/ip link set ${gpCfg.helpers.namespace}-ns up || true
          ${pkgs.iproute2}/bin/ip netns exec ${gpCfg.helpers.namespace} ${pkgs.iproute2}/bin/ip link set lo up || true

          # Reconfigure it imperatively because configuration for some reason isn't saved after moving it... 
          ${pkgs.iproute2}/bin/ip netns exec ${gpCfg.helpers.namespace} ${pkgs.iproute2}/bin/ip route add default via ${ips.host} || true
        '';

        preStop = ''
          ${pkgs.iproute2}/bin/ip netns del managed-ns || true
        '';
      };
    }) (filterAttrs (_: gpCfg: gpCfg.helpers.namespace != null) cfg.groups);

    os.networking.nftables.tables = mapAttrs' (gpID: gpCfg:
      let
        ips = utils.gpIP (toIntBase10 gpID);
        args = {
          inherit (gpCfg) interface;
          inherit ips;
        };
      in {
        name = "gp${gpID}-default";
        value = {
          family = "inet";
          content = ''
            chain input {
              type filter hook input priority 0; policy accept;

              ${gpCfg.inputRules args}
            }

            chain prerouting {
              type nat hook prerouting priority -100;

              ${gpCfg.extraPrerouting args}
            }

            chain forward {
              type filter hook forward priority 0; policy accept;

              ${gpCfg.forwardRules args}
            }

            chain postrouting {
              type nat hook postrouting priority -100;

              ${gpCfg.extraPostrouting args}

              ${
                if gpCfg.gateway == null then
                  ""
                else ''
                  iifname != ${gpCfg.interface} return
                  oifname ${cfg.vpnInterface} snat ip to ${
                    resolveHostname
                    "${config.os.networking.hostName}.${cfg.vpnInterface}"
                  }
                  oifname ${cfg.homeInterface} snat ip to ${
                    resolveHostname "${config.os.networking.hostName}.home"
                  }
                ''
              }
            }
          '';
        };
      }) cfg.groups;

    microvm.vms = mapAttrs' (gpID: gpCfg:
      let vmName = gpCfg.helpers.microvm;
      ips = utils.gpIP (toIntBase10 gpID);
      in {
        name = vmName;
        value = {
          config = _: {
            networking.enable = true;
            os = {
              systemd.services.dhcpcd.enable = true;

              systemd.network = {
                enable = true;

                networks."20-lan" = {
                  matchConfig.MACAddress = [ "02:00:00:00:00:01" ];
                  matchConfig.Type = "ether";
                  dns = [
                    "8.8.8.8"
                    "1.1.1.1"
                  ];
                  networkConfig = {
                    Address = "${ips.guest}/30";
                    Gateway = ips.host;
                    IPv6AcceptRA = false;
                    LinkLocalAddressing = false;
                    DHCP = true;
                  };
                };
              };

              microvm = {
                interfaces = [{
                  type = "tap";
                  id = vmName;
                  mac = "02:00:00:00:00:01";
                }];
                shares = [{
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                  tag = "ro-store";
                  proto = "9p";
                }];
              };
            };
          };
        };
      }) (filterAttrs (_: gpCfg: gpCfg.helpers.microvm != null) cfg.groups);
  };
}
