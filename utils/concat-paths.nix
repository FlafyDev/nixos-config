_: let
  inherit (builtins) substring foldl';
in {
  concatPaths = paths: substring 1 (-1) (foldl' (acc: path: "${acc}/${path}") "" paths);
}
