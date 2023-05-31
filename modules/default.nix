{lib, ...}: let
  concatPaths = path1: path2: (toString path1) + "/" + (toString path2);
  getModules = ignoreDefault: path: let
    files = builtins.readDir path;
    moduleDirectory =
      if ignoreDefault
      then null
      else lib.lists.findFirst (f: f == "default.nix") null (lib.attrsets.attrNames files);
  in
    if moduleDirectory != null
    then [(concatPaths path moduleDirectory)]
    else
      lib.lists.flatten (lib.attrsets.mapAttrsToList (name: type:
        if (type == "regular")
        then
          if (ignoreDefault && name == "default.nix")
          then []
          else [(concatPaths path name)]
        else getModules false (concatPaths path name))
      files);
in {
  imports = getModules true ./.;
}
