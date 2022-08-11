{ lib, stdenvNoCC, fetchFromGitHub, fetchpatch, callPackage }: 

stdenvNoCC.mkDerivation rec {
  pname = "solana";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "maenDisease";
    repo = "BetterDiscordStuff";
    rev = "0d18c5a68d1a78f5abd81858fabebe5780afde84";
    sha256 = "hVknKIOgL8auGO28CwT+Yv42i11DK0okNgZF7bnOF7M=";
  };

  installPhase = ''
    mkdir -p $out/
    cp Themes/Solana/Solana.theme.css $out/theme.css
  '';

  passthru.themeName = "Solana";
}