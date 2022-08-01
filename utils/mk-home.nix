username: profile: { home-manager, nixpkgs, ... }:
with nixpkgs.lib;
let
  configs = (map (cfg: import (../configs + cfg + ".nix")) profile.configs);
  systemModules = (map (cfg: cfg.system) (filter (cfg: cfg ? system) configs));
  homeModules = (map (cfg: cfg.home) (filter (cfg: cfg ? home) configs));
in (flatten [
  (if (profile ? system) then profile.system else [])
  systemModules
  {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "adbusers" "scanner" "lp" ];
    };
  }
  home-manager.nixosModules.home-manager
  {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${username} = { ... }: {
      imports = (flatten [
        (import ../overlays.nix).home
        (if (profile ? home) then profile.home else [])
        homeModules
      ]);

      home.stateVersion = "21.11";
    };
  }
])