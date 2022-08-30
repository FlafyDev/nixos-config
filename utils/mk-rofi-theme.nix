{ type, style, colorScheme }: { lib, stdenvNoCC, fetchFromGitHub }: 

stdenvNoCC.mkDerivation {
  pname = "adi1090x-rofi-themes";
  version = "2022-08-14";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "307deb9b9203a0f3d343c98f87d96eefa2a7ae96";
    sha256 = "NocMC9tkoG7HysM1PegY+9JOc1GtYo+b5GHah8rZCHM=";
  };

  installPhase = ''
    mkdir -p $out/
    cp files/launchers/type-${builtins.toString type}/style-${builtins.toString style}.rasi $out/config.rasi
    cat files/colors/${colorScheme}.rasi >> $out/config.rasi
    sed -i '/^@import/d' $out/config.rasi
  '';
}

