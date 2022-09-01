{ lib, stdenvNoCC, fetchFromGitHub, }: 

stdenvNoCC.mkDerivation rec {
  pname = "hide-disabled-emojis";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "rauenzi";
    repo = "BetterDiscordAddons";
    rev = "6050e383c5f63915b8f8d064b2971a0a3c69c81d";
    sha256 = "dW+w3XOcCsS9/xCwyDhsKlB5TEsPohf2bCtKHaRJA8c=";
  };

  installPhase = ''
    mkdir -p $out/
    cp Plugins/HideDisabledEmojis/HideDisabledEmojis.plugin.js $out/plugin.js
  '';

  passthru.pluginName = "HideDisabledEmojis";
}
