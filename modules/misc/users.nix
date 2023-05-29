{
  lib,
  config,
  ...
}: let
  cfg = config.users;
  inherit (lib) mkOption types;
in {
  options.users = {
    main = mkOption {
      type = with types; str;
      description = ''
        List of package names that are allowed to be installed dispite being unfree.
      '';
    };
  };

  config = {
    os = {
      users.users.root = {
        group = "root";
        password = "$y$j9T$s7BZx6bB6XXKsM.nGXaeq/$rUV6f4K8c1SuxPe0HnngsFhgDDTa9Cj1oWKGfaPuik5";
        isSystemUser = true;
      };
      users.users.${cfg.main} = {
        group = cfg.main;
        password = "$y$j9T$lBa.z5DPjmFIpGgdlajll.$M3ioCotjdUW178tOJpGT7OtK../klyeSZQV2zjYblf8";
        isNormalUser = true;
      };
      users.mutableUsers = false;
    };
    hmUsername = cfg.main;
  };
}
