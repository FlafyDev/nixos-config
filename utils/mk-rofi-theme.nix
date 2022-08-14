{ type, style, colorScheme }: { lib, stdenvNoCC, fetchFromGitHub }: 

stdenvNoCC.mkDerivation {
  pname = "adi1090x-rofi-themes";
  version = "2022-08-14";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "rofi";
    rev = "8e8f44eb8aceb349a29f53c5f211ad0e45e83aa6";
    sha256 = "BzgmCJJAzay5AMPU+DE+qFn2r2+RsY/akGQYRH1mHW0=";
  };

  installPhase = ''
    mkdir -p $out/
    cp files/launchers/type-${builtins.toString type}/style-${builtins.toString style}.rasi $out/config.rasi
    cat files/launchers/colors/${colorScheme}.rasi >> $out/config.rasi
    sed -i '/^@import/d' $out/config.rasi
  '';
}

