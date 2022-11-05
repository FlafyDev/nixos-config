{ lib, stdenvNoCC, fetchFromGitHub, theme, src }: 

# last rev tested: 307deb9b9203a0f3d343c98f87d96eefa2a7ae96
stdenvNoCC.mkDerivation {
  pname = "adi1090x-rofi-themes";
  version = "2022-08-14";

  inherit src;

  installPhase = ''
    mkdir -p $out/
    cp files/launchers/type-${builtins.toString theme.type}/style-${builtins.toString theme.style}.rasi $out/config.rasi
    cat files/colors/${theme.colorScheme}.rasi >> $out/config.rasi
    sed -i '/^@import/d' $out/config.rasi
  '';
}
