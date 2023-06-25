{lib, ...}: let
  inherit (lib) attrNames optional foldlAttrs hasSuffix;
  inherit (builtins) elem readDir;

  concatPaths = path1: path2: (toString path1) + "/" + (toString path2);
  getModules = ignoreDefault: path: let
    files = readDir path;
    isModuleDirectory = !ignoreDefault && elem "default.nix" (attrNames files);
  in
    if isModuleDirectory
    then [(concatPaths path "default.nix")]
    else
      foldlAttrs (
        acc: name: type:
          acc
          ++ (
            if (type == "regular")
            then optional (name != "default.nix" && hasSuffix "nix" name) (concatPaths path name)
            else getModules false (concatPaths path name)
          )
      ) []
      files;
in {
  imports = getModules true ./.;
}
