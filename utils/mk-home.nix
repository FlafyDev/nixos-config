username: profile: system: { home-manager, nixpkgs, ... }@inputs:
with nixpkgs.lib;
let
  additions = import ../additions.nix;
  configs = (map (cfg: import (../configs + cfg)) profile.configs) ++ [ profile system ];
  systemModules = (map (cfg: cfg.system) (filter (cfg: cfg ? system) configs));
  homeModules = (map (cfg: cfg.home) (filter (cfg: cfg ? home) configs));
in {
  system = system.systemType;
  modules = (flatten [
    systemModules
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "adbusers" "scanner" "lp" ];
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
