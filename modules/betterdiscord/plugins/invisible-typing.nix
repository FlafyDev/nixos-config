{ lib, stdenvNoCC, fetchFromGitHub, }: 

stdenvNoCC.mkDerivation rec {
  pname = "invisible-typing";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "Strencher";
    repo = "BetterDiscordStuff";
    rev = "cf69ee33d6b269bf0483ad459e54474bbae77df8";
    sha256 = "eB/6bccgb4uTX/wgL0Uv/X1fO8KySonNUdoioou0cwk=";
  };

  installPhase = ''
    mkdir -p $out/
    cp InvisibleTyping/InvisibleTyping.plugin.js $out/plugin.js
  '';

  passthru.pluginName = "InvisibleTyping";
}
