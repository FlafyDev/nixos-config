{
  lib,
  utils,
  ...
}: let
  inherit (lib) attrNames optional foldlAttrs hasSuffix;
  inherit (builtins) elem readDir;

  getModulesRecur = ignoreDefault: path: let
    files = readDir path;
    isModuleDirectory = !ignoreDefault && elem "default.nix" (attrNames files);
  in
    if isModuleDirectory
    then [(utils.concatPaths [path "default.nix"])]
    else
      foldlAttrs (
        acc: name: type:
          acc
          ++ (
            if (type == "regular")
            then optional (name != "default.nix" && hasSuffix "nix" name) (utils.concatPaths [path name])
            else getModulesRecur false (utils.concatPaths [path name])
          )
      ) []
      files;
  getModules = modulesPath: getModulesRecur true modulesPath;
in {
  inherit getModules;
  getModulesForHost = host:
    (utils.getModules (toString ../modules))
    ++ (
      if builtins.pathExists ../hosts/${host}/modules
      then utils.getModules (toString ../hosts/${host}/modules)
      else []
    )
    ++ [(toString ../hosts/${host}/default.nix)];
}
