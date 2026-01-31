{ inputs, lib, config, combinedManager, pkgs, utils, ... }:
let
  inherit (lib)
    mkOption mkEnableOption types mkIf mapAttrs __curPos mkDefault mkMerge;
  inherit (utils) getModules;
  cfg = config.microvm;
in {
  options = {
    microvm = {
      enable = mkEnableOption "microvm";
      vms = mkOption {
        type = types.attrsOf (types.submodule ({ name, ... }@modArgs:
          let
            modConfig = modArgs.config;
            vmName = name;
          in {
            options = {
              specialArgs = mkOption {
                type = with types; attrsOf unspecified;
                default = { };
              };
              config = mkOption {
                description = lib.mdDoc ''
                  A specification of the desired configuration of this
                  VM as a Combined Manager module.
                '';
                default = { };
                type = lib.mkOptionType {
                  name = "Toplevel Combined Manager config";
                  merge = _loc: defs:
                    ((import combinedManager).nixosSystem {
                      inherit inputs;
                      configuration = {
                        modules = [{
                          _file = "module at ${__curPos.file}:${
                              toString __curPos.line
                            }";
                          config = {
                            users.main = mkDefault vmName;
                            users.host = mkDefault vmName;
                            microvm.enable = false;
                            osModules = [ inputs.microvm.nixosModules.microvm ];
                            networking.enable = true;
                            os.services.openssh = {
                              enable = true;
                              startWhenNeeded = true;
                              settings = {
                                PermitRootLogin = "yes";
                                PasswordAuthentication = true;
                              };
                            };
                          };
                        }] ++ (getModules (toString ./..))
                          ++ (map (x: x.value) defs);
                        prefix = [ "microvm" "vms" vmName "config" ];

                        specialArgs = {
                          configs = { };
                        } // modConfig.specialArgs;

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
  config = mkMerge [
    {
      inputs = {
        microvm.url = "github:FlafyDev/microvm.nix/flafy-main";
        microvm.inputs.nixpkgs.follows = "nixpkgs";
      };
      osModules = mkIf cfg.enable [ inputs.microvm.nixosModules.host ];
    }
    (mkIf cfg.enable {
      os.microvm.vms = mapAttrs (vmName: vmCfg: {
        autostart = lib.mkDefault true;
        restartIfChanged = lib.mkDefault true;
        evaluatedConfig = vmCfg.config;
      }) cfg.vms;
    })

  ];
}
