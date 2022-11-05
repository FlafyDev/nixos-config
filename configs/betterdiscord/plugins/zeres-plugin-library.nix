{ lib, stdenvNoCC, fetchFromGitHub, }: 

stdenvNoCC.mkDerivation rec {
  pname = "zeres-plugin-library";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "rauenzi";
    repo = "BDPluginLibrary";
    rev = "b3f40780361f7de2f2fec8d25e86866bdb89dcab";
    sha256 = "qPlar9d7u9TqMFtvtlz8SVeGgX/WtfON92YvZwrPYh4=";
  };

  installPhase = ''
    mkdir -p $out/
    cp release/0PluginLibrary.plugin.js $out/plugin.js
  '';

  passthru.pluginName = "0PluginLibrary";
}
