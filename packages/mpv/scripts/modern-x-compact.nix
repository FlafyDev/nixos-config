{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mpv-modern-x-compact";
  version = "unstable-2022-07-20";

  src = fetchFromGitHub {
    owner = "1-minute-to-midnight";
    repo = "mpv-modern-x-compact";
    rev = "0d26e53ffefbbcfefc84d2d1d9bbb2daf51b1809";
    sha256 = "1qq8p3cafrsl9bdmi493cmrn7dnbzyhz4bzn0zf1a65sig6x7hn9";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts
    cp modernx.lua $out/share/mpv/scripts
    mkdir -p $out/share/mpv/fonts
    cp modernx-osc-icon.ttf $out/share/mpv/fonts
    runHook postInstall
  '';

  passthru.scriptName = "modernx.lua";
  passthru.fonts = ["modernx-osc-icon.ttf"];

  meta = with lib; {
    description = "Compact version of modern-x osc for mpv with a neat web-player type UI";
    homepage = "https://github.com/1-minute-to-midnight/mpv-modern-x-compact";
    license = licenses.unlicense;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}