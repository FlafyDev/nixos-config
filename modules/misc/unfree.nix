{
  lib,
  config,
  ...
}: let
  cfg = config.unfree;
in
  with lib; {
    options.unfree = {
      allowed = mkOption {
        type = with types; listOf str;
        default = [];
        description = ''
          List of package names that are allowed to be installed dispite being unfree.
        '';
      };
    };

    config = {
      nixpkgs.config.allowUnfreePredicate =
        mkForce (pkg:
          builtins.elem (lib.getName pkg) cfg.allowed);
    };
  }
