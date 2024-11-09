{
  lib,
  config,
  ...
}: let
  cfgUnfree = config.unfree;
  cfgInsecure = config.insecure;

  # nixpkgs: pkgs/stdenv/generic/check-meta.nix
  getNameWithVersion = attrs: attrs.name or ("${attrs.pname or "«name-missing»"}-${attrs.version or "«version-missing»"}");

  inherit (lib) mkForce mkOption types optional length foldl';
in {
  options = {
    unfree = {
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
          Whether to warn about allowed unfree packages.
        '';
      };
    };
    insecure = {
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
          Whether to warn about allowed insecure packages.
        '';
      };
    };
  };

  config = {
    os = {
      warnings = let
        unfreeWarning =
          foldl' (sum: cur: "${sum}\n- ${cur}")
          "\n${toString (length cfgUnfree.allowed)} allowed unfree packages:"
          cfgUnfree.allowed;
        insecureWarning =
          foldl' (sum: cur: "${sum}\n- ${cur}")
          "\n${toString (length cfgInsecure.allowed)} allowed insecure packages:"
          cfgInsecure.allowed;
      in
        (optional (cfgUnfree.warn && length cfgUnfree.allowed != 0) unfreeWarning) ++
        (optional (cfgInsecure.warn && length cfgInsecure.allowed != 0) insecureWarning);

      nixpkgs.config.allowUnfreePredicate =
        mkForce (pkg:
          builtins.elem (getNameWithVersion pkg) cfgUnfree.allowed);

      nixpkgs.config.allowInsecurePredicate =
        mkForce (pkg:
          builtins.elem (getNameWithVersion pkg) cfgInsecure.allowed);
    };
  };
}
