{
  pkgs,
  lib,
  config,
  utils,
  inputs,
  combinedManager,
  ...
}: let
  inherit (builtins) mapAttrs tail elemAt;
  inherit (lib) mkEnableOption mkIf mkOption optionals mapAttrs' __curPos types mkForce mkDefault;
  inherit (utils) resolveHostname getModules;
  cfg = config.networking.setupVM;
in {
  options.networking = {
    setupVM = {
      enable = mkEnableOption "setupVM";
      vms = mkOption {
        type = with types; attrsOf (submodule (_: {
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
      routingPolicyRules = optionals (vmCfg.gateway == "vps") [
        {
          Family = "ipv4";
          IncomingInterface = vmName;
          Table = 2;
        }
      ];
    }) cfg.vms;

    os.microvm.vms = mapAttrs (vmName: _vmCfg: {
      autostart = true;
      restartIfChanged = true;
      configEvalFunc = args: ((import combinedManager).nixosSystem {
        inherit inputs;
        configuration = {
          modules = [
            (_: {
              hm = {home.stateVersion = "23.11";};
            })
          # modules = (tail (tail args.modules)) ++ [
            # (getModules (toString ../.)) ++ [
              # (_: {
              #   # _file = "module at ${__curPos.file}:${toString __curPos.line}";
              #   options = {
              #     hm = mkOption {
              #       type = with types; attrsOf anything;
              #       default = {};
              #     };
              #     hmModules = mkOption {
              #       type = with types; listOf anything;
              #       default = [];
              #     };
              #     hmUsername = mkOption {
              #       type = with types; str;
              #       default = "";
              #     };
              #   };
              #   config = {
              #     osModules = [inputs.microvm.nixosModules.microvm];
              #     # users.main = mkDefault "";
              #     # users.host = mkDefault vmName;
              #     # microvm.host = false;
              #     os.passthru = null;
              #     # os.sound.enable = false;
              #
              #     os.system.stateVersion = "23.11";
              #     hm.home.stateVersion = "23.11";
              #   #   os = {
              #   #     # nixpkgs = if options.nixpkgs?hostPlatform && host.options.nixpkgs.hostPlatform.isDefined
              #   #     #           then { inherit (host.osConfig.nixpkgs) hostPlatform; }
              #   #     #           else { inherit (host.osConfig.nixpkgs) localSystem; }
              #   #     # ;
              #   #   };
              #   };
              # })
            ];
          inherit (args) prefix;

          # useHomeManager = false;

          # The system is inherited from the host above.
          # Set it to null, to remove the "legacy" entrypoint's non-hermetic default.
          inherit (pkgs) system;
        };
      });
      config = {
        os = {
          users.users.root = {
            group = "root";
            password = "itsfine";
            isSystemUser = true;
          };

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

            ${if vmCfg.gateway == null then '''' else ''
              iifname != ${vmName} return
              oifname wg_vps snat ip to ${resolveHostname "${config.os.networking.hostName}.wg_vps"}
              snat ip to ${resolveHostname "${config.os.networking.hostName}.home"}
            ''}
          }
        '';
      };
    }) cfg.vms;
  };
}
