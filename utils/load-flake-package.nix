{lib, ...}: let
  inherit (lib) foldl';
in {
  flPkgs = system: input: input.packages.${system}.default; # flPkgs inputs.guifetch
  flPkgs' = system: input: foldl' (sum: n: sum.${n}) input.packages.${system}; # flPkgs' inputs.guifetch [ "guifetch" ]
  flLPkgs = system: input: input.legacyPackages.${system}.default; # flLPkgs inputs.guifetch
  flLPkgs' = system: input: foldl' (sum: n: sum.${n}) input.legacyPackages.${system}; # flLPkgs' inputs.guifetch [ "guifetch" ]
}
