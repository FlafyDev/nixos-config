{ lib, stdenvNoCC, fetchFromGitHub, fetchpatch, callPackage, nodejs-16_x, yarn, yarn2nix, buildYarnPackage }: 

stdenvNoCC.mkDerivation rec {
  pname = "betterdiscord-asar";
  version = "1.6.2";

  src = buildYarnPackage {
    src = fetchFromGitHub {
      owner = "FlafyDev";
      repo = "BetterDiscord-Yarn";
      rev = "v${version}";
      sha256 = "Pf1VeIiMX9ujCepsjUrqIqqqZGK92+AN2pb8ZXZS96U=";
    };
    yarnBuildMore = "yarn dist";
  };

  installPhase = ''
    mkdir -p $out/
    cp dist/betterdiscord.asar $out/betterdiscord.asar
  '';
}

# src = fetchFromGitHub {
#   owner = "BetterDiscord";
#   repo = "BetterDiscord";
#   rev = version;
#   sha256 = "rXxYSbeQdUjle0dhEsbAQyxXdqSoTWEuuPFtOzWJ52M=";
# };
