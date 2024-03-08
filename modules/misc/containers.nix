{
  lib,
  osOptions,
  config,
  osConfig,
  combinedManager,
  utils,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mapAttrs types __curPos mkDefault head;
  inherit (utils) getModules;
  cfg = config.containers;
in {
  options = {
    # Basically copy `containers` from nixpkgs but:
    # - merge `config` the way I want.
    containers = mkOption {
      default = {};
      type = types.attrsOf (
        types.submodule (
          {
            name,
            config,
            options,
            ...
          } @ args: let
            moduleResult = (head (head osOptions.containers.type.nestedTypes.elemType.getSubModules).imports) args;
          in
            moduleResult
            // {
              options =
                moduleResult.options
                // {
                  config = mkOption {
                    description = lib.mdDoc ''
                      A specification of the desired configuration of this
                      container, as a Combined Manager module.
                    '';
                    type = lib.mkOptionType {
                      name = "Toplevel Combined Manager config";
                      merge = _loc: defs:
                        ((import combinedManager).nixosSystem {
                          inherit inputs;
                          configuration = {
                            modules =
                              [
                                ({options, ...}: {
                                  _file = "module at ${__curPos.file}:${toString __curPos.line}";
                                  options = {
                                    hm = mkOption {
                                      type = with types; attrsOf anything;
                                      default = {};
                                    };
                                    hmModules = mkOption {
                                      type = with types; listOf anything;
                                      default = [];
                                    };
                                    hmUsername = mkOption {
                                      type = with types; str;
                                      default = "";
                                    };
                                  };
                                  config = {
                                    users.main = "";
                                    users.host = mkDefault name;
                                    os = {
                                      # nixpkgs = if options.nixpkgs?hostPlatform && host.options.nixpkgs.hostPlatform.isDefined
                                      #           then { inherit (host.osConfig.nixpkgs) hostPlatform; }
                                      #           else { inherit (host.osConfig.nixpkgs) localSystem; }
                                      # ;

                                      networking.useHostResolvConf = lib.mkForce false;
                                      boot.isContainer = true;
                                      networking.useDHCP = false;
                                    };
                                  };
                                })
                              ]
                              ++ (getModules (toString ../../modules))
                              ++ (map (x: x.value) defs);
                            prefix = ["containers" name];

                            specialArgs = {configs = {};} // config.specialArgs;
                            useHomeManager = false;

                            # The system is inherited from the host above.
                            # Set it to null, to remove the "legacy" entrypoint's non-hermetic default.
                            inherit (osConfig.nixpkgs) system;
                          };
                        })
                        .config;
                    };
                  };
                };
            }
        )
      );

      description = "Combined Manager containers.";
    };
  };

  config = {
    os.containers =
      mapAttrs (
        _name: containerConfig:
          (builtins.removeAttrs containerConfig ["pkgs" "config"])
          // {
            bindMounts =
              {
                "/etc/resolv.conf" = {
                  hostPath = toString (pkgs.writeText "resolv.conf" ''
                    nameserver 9.9.9.9
                    nameserver 1.1.1.1
                  '');
                  isReadOnly = true;
                };
              }
              // containerConfig.bindMounts;
          }
      )
      cfg;
  };
}
