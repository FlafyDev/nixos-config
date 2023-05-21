{
  lib,
  config,
  ...
}: let
  cfg = config.users;
in
  with lib; {
    options.users = {
      main = mkOption {
        type = with types; str;
        description = ''
          List of package names that are allowed to be installed dispite being unfree.
        '';
      };
    };

    config = {
      sys = {
        users.users.root = {
          group = "root";
          password = "root";
          isSystemUser = true;
        };
        users.users.${cfg.main} = {
          group = cfg.main;
          # TODO
          password = "aaa";
          isNormalUser = true;
        };
        users.mutableUsers = false;
      };
      home.home.username = cfg.main;
    };
  }
