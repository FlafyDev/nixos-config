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
in let
  additions = import ../additions.nix;
  profileConfigs = (profile.configs configs) ++ [ profile system ];
  systemModules = (map (cfg: cfg.system) (filter (cfg: cfg ? system) profileConfigs));
  homeModules = (map (cfg: cfg.home) (filter (cfg: cfg ? home) profileConfigs));
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
