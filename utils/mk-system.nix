{
  username,
  args ? {},
}: profile: {
  system,
  inputs,
}:
with inputs.nixpkgs.lib; let
  filterMap = list: attr:
    map (item: item.${attr}) (filter (item: item ? ${attr}) list);

  passedArgs =
    args
    // {
      inherit inputs;
      inherit username;
    };

  configs = import ./get-all-configs.nix ../configs;
  getDeepConfigs = config:
    flatten ((
        if config ? configs
        then (map getDeepConfigs (config.configs configs))
        else []
      )
      ++ [config]);
  selectedConfigs = (getDeepConfigs profile) ++ (getDeepConfigs system);

  addConfigs = map (add: add (inputs // {args = passedArgs;})) (filterMap selectedConfigs "add");

  modulesConfigs = flatten (filterMap addConfigs "modules");
  homeModulesConfigs = flatten (filterMap addConfigs "homeModules");
  overlaysConfigs = filterMap addConfigs "overlays";

  systemConfigs = filterMap selectedConfigs "system";
  homeConfigs = filterMap selectedConfigs "home";
in {
  system = system.systemType;
  specialArgs = passedArgs;
  modules = flatten [
    systemConfigs
    modulesConfigs
    (moduleArgs: {
      nixpkgs.overlays = flatten (map (ovrCfg: ovrCfg moduleArgs) overlaysConfigs);
    })
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
          "docker"
          "deluge"
        ];
      };
    }
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = passedArgs;
      home-manager.users.${username} = {...}: {
        imports = flatten homeModulesConfigs ++ homeConfigs;
      };
    }
  ];
}
