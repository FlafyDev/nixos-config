{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  gtk-engine-murrine,
}:
stdenvNoCC.mkDerivation {
  pname = "adwaita-dark-amoled";
  version = "2021.07.12";

  src = fetchFromGitLab {
    owner = "tearch-linux/artworks/themes-and-icons";
    repo = "adwaita-dark-amoled";
    rev = "52d3774f0bb91c8802ce4ab04e23ef0480d4da8c";
    sha256 = "sha256-BfJc0LXDClYSAR1gvXRPDM+orP/fbpiy7BG94+dlcoo=";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/Adwaita-dark-amoled
    cp -r * $out/share/themes/Adwaita-dark-amoled
    runHook postInstall
  '';

  meta = with lib; {
    description = "Adwaita gtk theme full black theme";
    homepage = "https://www.gnome-look.org/p/1553851/";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = [];
  };
}
