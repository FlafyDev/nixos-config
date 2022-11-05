{
  username,
  args,
}: profile: {
  system,
  inputs,
}:
with inputs.nixpkgs.lib; let
  filterMap = list: attr:
    map (item: item.${attr}) (filter (item: item ? ${attr}) list);

  configs = import ./get-all-configs.nix ../configs;
  # configs = mapAttrs'
  #   (file: type:
  #     let
  #       name = builtins.match ''^(.*).nix$'' file;
  #     in
  #     attrsets.nameValuePair
  #       (builtins.elemAt (if builtins.isNull name then [ file ] else name) 0)
  #       (import (../configs + "/${file}"))
  #   )
  #   (builtins.readDir ../configs);
  getDeepConfigs = config:
    flatten ((
        if config ? configs
        then (map getDeepConfigs (config.configs configs))
        else []
      )
      ++ [config]);
  additions = import ../additions.nix;
  selectedConfigs = (getDeepConfigs profile) ++ (getDeepConfigs system);

  addConfigs = map (add: add inputs) (filterMap selectedConfigs "add");

  modulesConfigs = flatten (filterMap addConfigs "modules");
  homeModulesConfigs = flatten (filterMap addConfigs "homeModules");
  overlaysConfigs = filterMap addConfigs "overlays";

  systemConfigs = filterMap selectedConfigs "system";
  homeConfigs = filterMap selectedConfigs "home";
in {
  system = system.systemType;
  specialArgs =
    {
      inherit (inputs) nixpkgs;
    }
    // args;
  modules = flatten [
    systemConfigs
    modulesConfigs
    (moduleArgs: {
      nixpkgs.overlays = flatten (map (ovrCfg: ovrCfg moduleArgs) overlaysConfigs);
    })
    (additions.modules inputs)
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
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = args;
      home-manager.users.${username} = {...}: {
        imports =
          [
            ({...}: {
              imports = flatten homeModulesConfigs ++ (additions.homeModules inputs);
            })
          ]
          ++ homeConfigs;
      };
    }
  ];
}
