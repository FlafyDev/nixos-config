{
  pkgs,
  lib,
  config,
  utils,
  inputs,
  combinedManager,
  osConfig,
  ...
}: let
  inherit (builtins) mapAttrs tail elemAt;
  inherit (lib) mkEnableOption mkIf mkOption optionals mapAttrs' __curPos types mkForce mkDefault;
  inherit (utils) resolveHostname getModules;
  cfg = config.setupVM;
in {
  options = {
    setupVM = {
      enable = mkEnableOption "setupVM";
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
        default = [];
        description = "IPs that should always go through the home interface even if the gateway is the VPN";
      };
      vms = mkOption {
        type = with types; attrsOf (submodule ({name, ...}@modArgs: let
          modConfig = modArgs.config;
          vmName = name;
        in {
          options = {
            gateway = mkOption {
              type = nullOr (enum ["vpn" "home"]);
              default = null;
              description = "Name";
            };
            # package = mkOption {
            #   type = types.anything;
            #   default = cfg.vms.${vmName}.config.config.microvm.declaredRunner;
            #   description = "Package";
            # };
            inputRules = mkOption {
              type = str;
              default = "";
              example = ''
                iifname vm0 meta mark set 88
              '';
              description = "Input rules";
            };
            forwardRules = mkOption {
              type = str;
              default = "";
              example = ''
                # Accept all outgoing/incoming packets to the VM
                oifname vm0 meta mark set 89
                iifname vm0 meta mark set 89
              '';
              description = "Forward rules";
            };
            extraPrerouting = mkOption {
              type = str;
              default = "";
              example = ''
                # Redirect to vm0 all tcp 80 packets the host receives
                iifname != "vm0" tcp dport 80 dnat ip to 10.10.15.2
              '';
              description = "Extra prerouting";
            };
            extraPostrouting = mkOption {
              type = str;
              default = "";
              example = ''
                # give access to mera port 5000
                iifname vm0 ip daddr 10.0.0.41 tcp dport { 5000 } snat to 10.0.0.42
              '';
              description = "Extra postrouting";
            };
            specialArgs = mkOption {
              type = types.attrsOf types.unspecified;
              default = {};
            };
            config = mkOption {
              description = lib.mdDoc ''
                A specification of the desired configuration of this
                VM as a Combined Manager module.
              '';
              default = {};
              type = lib.mkOptionType {
                name = "Toplevel Combined Manager config";
                merge = _loc: defs: ((import combinedManager).nixosSystem {
                  inherit inputs;
                  configuration = {
                    modules = [{
                      _file = "module at ${__curPos.file}:${toString __curPos.line}";
                      config = {
                        users.main = mkDefault vmName;
                        users.host = mkDefault vmName;
                        microvm.host = false;
                        osModules = [inputs.microvm.nixosModules.microvm];
                        networking.enable = true;
                        os = {
                          services.openssh = {
                            enable = true;
                            startWhenNeeded = true;
                            settings.PermitRootLogin = "yes";
                          };

                          systemd.services.dhcpcd.enable = false;

                          systemd.network = {
                            enable = true;

                            networks."20-lan" = {
                              matchConfig.MACAddress = ["02:00:00:00:00:01"];
                              matchConfig.Type = "ether";
                              networkConfig = {
                                Address = "${resolveHostname "vm.${vmName}"}/30";
                                Gateway = resolveHostname "gateway.${vmName}";
                                DNS = resolveHostname "gateway.${vmName}";
                                IPv6AcceptRA = false;
                                LinkLocalAddressing = false;
                                DHCP = false;
                              };
                            };
                          };

                          microvm = {
                            interfaces = [
                              {
                                type = "tap";
                                id = vmName;
                                mac = "02:00:00:00:00:01";
                              }
                            ];
                            shares = [
                              {
                                source = "/nix/store";
                                mountPoint = "/nix/.ro-store";
                                tag = "ro-store";
                                proto = "9p";
                              }
                            ];
                          };
                        };
                      };
                    }] ++ (getModules (toString ../..)) ++ (map (x: x.value) defs);
                    prefix = ["setupVM" "vms" vmName "config"];

                    specialArgs = {configs = {};} // modConfig.specialArgs;

                    inherit (pkgs) system;
                  };
                });
              };
            };
          };
        }));
      };
    };
  };

  config = mkIf (config.networking.enable && cfg.enable) {
    os.services.resolved.extraConfig = ''
      DNSStubListenerExtra=0.0.0.0
    '';

    os.systemd.network.networks = (mapAttrs (vmName: vmCfg: {
      matchConfig.Name = vmName;
      networkConfig = {
        Address = "${resolveHostname "gateway.${vmName}"}/30";
        IPv6AcceptRA = false;
        DHCP = "no";
      };
      routes = [
        {
          Destination = "${resolveHostname "vm.${vmName}"}";
          Table = 2;
          Scope = "link";
        }
      ];
      routingPolicyRules = optionals (vmCfg.gateway == "vpn") [
        {
          Family = "ipv4";
          IncomingInterface = vmName;
          Table = 2;
        }
      ];
    }) cfg.vms) // {
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
    };

    os.microvm.vms = mapAttrs (vmName: vmCfg: {
      autostart = lib.mkDefault true;
      restartIfChanged = lib.mkDefault true;
      evaluatedConfig = vmCfg.config;
    }) cfg.vms;

    os.networking.nftables.tables = mapAttrs' (vmName: vmCfg: {
      name = "${vmName}-default";
      value = {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority 0; policy accept;

            ${vmCfg.inputRules}
          }

          chain prerouting {
            type nat hook prerouting priority -100;

            ${vmCfg.extraPrerouting}
          }

          chain forward {
            type filter hook forward priority 0; policy accept;

            ${vmCfg.forwardRules}
          }

          chain postrouting {
            type nat hook postrouting priority -100;

            ${vmCfg.extraPostrouting}

            ${if vmCfg.gateway == null then "" else ''
              iifname != ${vmName} return
              oifname ${cfg.vpnInterface} snat ip to ${resolveHostname "${config.os.networking.hostName}.${cfg.vpnInterface}"}
              oifname ${cfg.homeInterface} snat ip to ${resolveHostname "${config.os.networking.hostName}.home"}
            ''}
          }
        '';
      };
    }) cfg.vms;
  };
}
