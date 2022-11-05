inputs: let
  configs = import ./get-all-configs.nix ../configs;
  inputsConfig =
    builtins.foldl'
    (val1: val2: val1 // val2) {} (map (cfg:
      cfg.inputs or {}) (
      map (
        cfg:
          if builtins.typeOf cfg == "lambda"
          then (cfg {})
          else cfg
      )
      (builtins.attrValues configs)
    ));
in
  inputs // inputsConfig
