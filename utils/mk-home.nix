username: profile: { system, inputs, args }:
with inputs.nixpkgs.lib;
let
  configs = mapAttrs'
    (file: type:
      let
        name = builtins.match ''^(.*).nix$'' file;
      in
      attrsets.nameValuePair
        (builtins.elemAt (if builtins.isNull name then [ file ] else name) 0)
        (import (../configs + "/${file}"))
    )
    (builtins.readDir ../configs);
  getDeepConfigs = config: flatten ((if config ? configs then (map getDeepConfigs (config.configs configs)) else [ ]) ++ [ config ]);
  additions = import ../additions.nix;
  selectedConfigs = (getDeepConfigs profile) ++ (getDeepConfigs system);
  systemModules = map (cfg: cfg.system) (filter (cfg: cfg ? system) selectedConfigs);
  homeModules = map (cfg: cfg.home) (filter (cfg: cfg ? home) selectedConfigs);
in
{
  system = system.systemType;
  specialArgs = {
    inherit (inputs) nixpkgs;
  } // args;
  modules = flatten [
    systemModules
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "video"
          "networkmanager"
          "adbusers"
          "scanner"
          "lp"
        ];
      };
    }
    (additions.modules inputs)
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = args;
      home-manager.users.${username} = { ... }: {
        imports = flatten [
          ({ ... }: {
            imports = additions.homeModules inputs;
          })
          homeModules
        ];
      };
    }
  ];
}
