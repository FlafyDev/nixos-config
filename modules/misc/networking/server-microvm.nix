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
      vms = mkOption {
        type = with types; attrsOf (submodule ({name, ...}@modArgs: let 
          modConfig = modArgs.config;
          vmName = name;
        in {
          options = {
            gateway = mkOption {
              type = nullOr (enum ["vps" "home" "custom"]);
              default = null;
              description = "Name";
            };
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
                        os = {
                          services.openssh = {
                            enable = true;
                            startWhenNeeded = true;
                            settings.PermitRootLogin = "yes";
                          };

                          networking.useNetworkd = false;
                          networking.firewall.enable = false;
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
                                proto = "virtiofs";
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

    os.systemd.network.networks = mapAttrs (vmName: vmCfg: {
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
      routingPolicyRules = optionals (vmCfg.gateway == "vps") [
        {
          Family = "ipv4";
          IncomingInterface = vmName;
          Table = 2;
        }
      ];
    }) cfg.vms;

    os.microvm.vms = mapAttrs (vmName: vmCfg: {
      autostart = true;
      restartIfChanged = true;
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
              oifname wg_vps snat ip to ${resolveHostname "${config.os.networking.hostName}.wg_vps"}
              oifname enp14s0 snat ip to ${resolveHostname "${config.os.networking.hostName}.home"}
            ''}
          }
        '';
      };
    }) cfg.vms;
  };
}
