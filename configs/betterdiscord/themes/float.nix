{ lib, stdenvNoCC, fetchFromGitHub, fetchpatch, callPackage }: 

stdenvNoCC.mkDerivation rec {
  pname = "float";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "maenDisease";
    repo = "BetterDiscordStuff";
    rev = "5076d139a48cad78ed847324ad2167cce9a5d0e5";
    sha256 = "Cd/3/+t55/5nKQTVOmMk/Q3jaeOOIKKWdh7NbEMvchg=";
  };

  installPhase = ''
    mkdir -p $out/
    cp Themes/Float/zFloat.theme.css $out/theme.css
  '';

  passthru.themeName = "zFloat";
}
