{
  lib,
  config,
  ...
}: let
  cfg = config.unfree;
  inherit (lib) mkForce mkOption types;
in {
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
    os.nixpkgs.config.allowUnfreePredicate =
      mkForce (pkg:
        builtins.elem (lib.getName pkg) cfg.allowed);
  };
}
