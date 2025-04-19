# `listToNestedAttrs ["a", "b", "c"] 1` returns `a.b.c = 1`
_: let
  inherit (builtins) head tail;

  listToNestedAttrs = path: value:
    if path == [] 
    then value
    else {
      ${head path} = listToNestedAttrs (tail path) value;
    };
in
  { inherit listToNestedAttrs; }
