_: let
  inherit (builtins) concatLists elemAt length all isList isAttrs zipAttrsWith tail head;

  last =
    list:
    elemAt list (length list - 1);
  recursiveMerge = attrList:
    let f = attrPath:
      zipAttrsWith (n: values:
        if tail values == []
          then head values
        else if all isList values
          then (concatLists values)
        else if all isAttrs values
          then f (attrPath ++ [n]) values
        else last values
      );
    in f [] attrList;
in
  { inherit recursiveMerge; }
