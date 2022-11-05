{ lib, stdenvNoCC, fetchFromGitHub, fetchpatch, callPackage }: 

stdenvNoCC.mkDerivation rec {
  pname = "frosted-glass-blue";
  version = "1.0.0";

  executable = ./FrostedGlassBlue.theme.css;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/
    cp ${executable} $out/theme.css
  '';

  passthru.themeName = "FrostedGlassBlue";
}
