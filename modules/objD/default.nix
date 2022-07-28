{ lib, stdenv, fetchFromGitHub, buildDartPackage }:

buildDartPackage rec {
  pname = "objD";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "Stevertus";
    repo = pname;
    rev = version;
    sha256 = "0m17m2hmr5jprzqwmzfcjxd38di9ljxhrrz5acwm35lcgfhhsqgy";
  };

  specFile = "${src}/pubspec.yaml";
  lockFile = ./pub2nix.lock;

  meta = with lib; {
    description = "objD is a framework for developing Datapacks for Minecraft.";
    homepage = "https://objd.stevertus.com/";
    maintainers = [ ];
    license = licenses.bsd2;
  };
}