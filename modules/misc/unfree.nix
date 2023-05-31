{
  lib,
  config,
  ...
}: let
  cfg = config.unfree;
  inherit (lib) mkForce mkOption types optional length foldl';
in {
  options.unfree = {
    allowed = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        List of package names that are allowed to be installed dispite being unfree.
      '';
    };
    warn = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to warn about unfree packages.
      '';
    };
  };

  config = {
    os.warnings = let
      warning =
        foldl' (sum: cur: "${sum}\n- ${cur}")
        "\n${toString (length cfg.allowed)} unfree packages:"
        cfg.allowed;
    in
      optional (cfg.warn && length cfg.allowed != 0) warning;
    os.nixpkgs.config.allowUnfreePredicate =
      mkForce (pkg:
        builtins.elem (lib.getName pkg) cfg.allowed);
  };
}
