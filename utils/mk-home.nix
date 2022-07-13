username: exps: home-manager: 
[
  exps.system
  {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "adbusers" ];
    };
  }
  home-manager.nixosModules.home-manager
  {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${username} = exps.home;
  }
]