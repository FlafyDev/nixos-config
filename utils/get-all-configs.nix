_configsEntry: let
  mapAttrs' = f: set:
    builtins.listToAttrs (map (attr: f attr set.${attr}) (builtins.attrNames set));
  nameValuePair = name: value: {inherit name value;};
in
  mapAttrs'
  (
    file: _type: let
      name = builtins.match ''^(.*).nix$'' file;
    in
      nameValuePair
      (builtins.elemAt (
          if builtins.isNull name
          then [file]
          else name
        )
        0)
      (import (../configs + "/${file}"))
  )
  (builtins.readDir ../configs)
