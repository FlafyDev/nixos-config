{
  gcc12Stdenv,
  fetchFromGitHub,
  hyprland,
  pkg-config,
  lib,
  gnumake,
}:
gcc12Stdenv.mkDerivation {
  pname = "hyprlens";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Duckonaut";
    repo = "hyprlens";
    rev = "2c2f84b8b8f9aa86c01568cedf6699b13c681ee1";
    sha256 = "sha256-xSjgIzU0e6dUbmxdbchqVoGoyDZf3zUfrAYyXZbjm2Y=";
  };

  nativeBuildInputs = [gnumake pkg-config];

  buildInputs =
    [hyprland.dev]
    ++ hyprland.buildInputs;

  configurePhase = ''
    export HYPRLAND_HEADERS=${hyprland.dev}
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp hyprlens.so $out/lib/libhyprlens.so
  '';

  dontStrip = true;

  meta = with lib; {
    homepage = "https://github.com/Duckonaut/hyprlens";
    description = "A small plugin to provide a shared image as the background for transparent windows.";
    # license = licenses.nolicense;
    platforms = platforms.linux;
  };
}
# {
#   gcc12Stdenv,
#   fetchFromGitHub,
#   hyprland,
#   pkg-config,
#   lib,
#   gnumake,
#   jq,
#   unixtools,
#   cmake,
# }:
# gcc12Stdenv.mkDerivation {
#   pname = "hyprlens";
#   version = "1.0.0";
#
#   src = fetchFromGitHub {
#     owner = "Duckonaut";
#     repo = "hyprlens";
#     rev = "2c2f84b8b8f9aa86c01568cedf6699b13c681ee1";
#     sha256 = "sha256-xSjgIzU0e6dUbmxdbchqVoGoyDZf3zUfrAYyXZbjm2Y=";
#   };
#
#   preConfigure = ''
#     cp ${./CMakeLists.txt} ./CMakeLists.txt
#     ls -la
#   '';
#
#   nativeBuildInputs = [cmake pkg-config];
#
#   buildInputs =
#     [hyprland.dev]
#     ++ hyprland.buildInputs;
#
#   # no noticeable impact on performance and greatly assists debugging
#   cmakeBuildType = "Debug";
#   dontStrip = true;
#
#   meta = with lib; {
#     homepage = "https://github.com/Duckonaut/hyprlens";
#     description = "A small plugin to provide a shared image as the background for transparent windows.";
#     # license = licenses.nolicense;
#     platforms = platforms.linux;
#   };
# }
