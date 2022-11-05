{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "mpv-modern-x-compact";
  version = "unstable-2022-07-20";

  src = fetchFromGitHub {
    owner = "1-minute-to-midnight";
    repo = "mpv-modern-x-compact";
    rev = "9a437fb9936375ff0ca7c844a349398aefbc2c3a";
    sha256 = "Yp1ukGQGH/xguAkvz6AndkUF7fLOmq42QdR9hntzsvE=";
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
