{ lib, stdenvNoCC, fetchFromGitHub, fetchpatch, callPackage, nodejs-16_x, yarn, yarn2nix, buildYarnPackage }: 

stdenvNoCC.mkDerivation rec {
  pname = "betterdiscord-asar";
  version = "v1.6.1";

  src = buildYarnPackage {
    src = fetchFromGitHub {
      owner = "FlafyDev";
      repo = "BetterDiscord-Yarn";
      rev = version;
      sha256 = "RmCJR9Ua2jamOFMXSG71khwbtAd0zpi3PwVZw9gQMFI=";
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