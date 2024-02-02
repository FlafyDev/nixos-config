# Not a module!
{lib, ...}: let
  inherit (builtins) readDir;
  inherit (lib) foldlAttrs optional hasSuffix;

  inherit ((import ./concat-paths.nix {inherit lib;})) concatPaths;

  utils =
    foldlAttrs (
      acc: name: type:
        acc
        // (
          if (type == "regular" && name != "default.nix" && hasSuffix "nix" name)
          then import (concatPaths [(toString ./.) name]) {inherit lib utils;}
          else {}
        )
    ) {}
    (readDir ./.);
in
  utils
