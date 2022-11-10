{stdenvNoCC}:
stdenvNoCC.mkDerivation rec {
  pname = "frosted-glass-green";
  version = "1.0.0";

  executable = ./FrostedGlassGreen.theme.css;

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/
    cp ${executable} $out/theme.css
  '';

  passthru.themeName = "FrostedGlassGreen";
}
