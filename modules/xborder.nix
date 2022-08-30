{ lib,
  stdenvNoCC,
  fetchFromGitHub,
  python310,
  libwnck,
  makeWrapper,
  gtk3,
  wrapGAppsHook,
  gobject-introspection,
  libnotify,
  ...
}: 

stdenvNoCC.mkDerivation rec {
  pname = "xborder";
  version = "2022-08-30";

  src = fetchFromGitHub {
    owner = "deter0";
    repo = pname;
    rev = "fa50c9040c61e4ce17b2ada4de3b4a0e215e087a";
    sha256 = "Mrt5cm3z4Qt5trPoLLgKJaA88O/z0GYGNI7NaaPULCY=";
  };

  nativeBuildInputs = [
    wrapGAppsHook
    libwnck
    gobject-introspection
    makeWrapper
  ];

  buildInputs = [
    gtk3
    (python310.withPackages (ps: with ps; [
      pycairo
      pygobject3
      requests
    ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp xborders $out/bin/xborder
    chmod +x $out/bin/xborder
    wrapProgram $out/bin/xborder --set PATH ${lib.makeBinPath [ libnotify ]}
  '';
}

# buildPythonPackage rec {
#  
#   preBuild = ''
#     cat >setup.py <<'EOF'
#     from setuptools import setup
#     setup(
#       name="xborder",
#       scripts=[
#         "xborders",
#       ],
#       install_requires=[
#         "pycairo",
#         "pygobject3"
#       ],
#     )
#     EOF
#   '';
#
#   postInstall = ''
#     echo $(cd $out/bin ; ls)
#     mv -v $out/bin/xborders $out/bin/xborder
#   '';
#
#   propagatedBuildInputs = [ 
#     
#     
#     
#   ];
# }
#
