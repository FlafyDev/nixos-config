{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk-engine-murrine,
}:
stdenvNoCC.mkDerivation {
  pname = "colloid-dark-edit";
  version = "git";

  src = fetchFromGitHub {
    owner = "AmirDahan";
    repo = "dotfiles";
    rev = "151c4b8950096162296e886daa549e78e9f19c68";
    sha256 = "sha256-BUD7ZEtgy7UZi0cGT65UijigzHv6YEXMrfydaO3qEME=";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/
    cp -r .themes/* $out/share/themes/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Colloid Dark Edited";
    maintainers = [];
  };
}

