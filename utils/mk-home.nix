username: profile: system: { home-manager, nixpkgs, ... }@inputs:
with nixpkgs.lib;
let 
  configs = mapAttrs' (file: type: let
      name = builtins.match ''^(.*).nix$'' file;
    in 
      attrsets.nameValuePair 
      (builtins.elemAt ( if builtins.isNull name then [ file ] else name ) 0)
      (import (../configs + "/${file}"))
  ) (builtins.readDir ../configs);
  getDeepConfigs = (config: flatten ((if config ? configs then (map (cfg: getDeepConfigs cfg) (config.configs configs)) else []) ++ [ config ]));
in let
  additions = import ../additions.nix;
  selectedConfigs = (getDeepConfigs profile) ++ (getDeepConfigs system);
  systemModules = (map (cfg: cfg.system) (filter (cfg: cfg ? system) selectedConfigs));
  homeModules = (map (cfg: cfg.home) (filter (cfg: cfg ? home) selectedConfigs));
in {
  system = system.systemType;
  specialArgs = { inherit (inputs) nixpkgs; };
  modules = (flatten [
    systemModules
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel" "video" "networkmanager" "adbusers" "scanner" "lp"
        ];
      };
    }
    (additions.modules inputs)
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = { ... }: {
        imports = (flatten [
          ({ ... }: {
            imports = additions.homeModules inputs;
          })
          homeModules
        ]);
      };
    }
  ]);
}
