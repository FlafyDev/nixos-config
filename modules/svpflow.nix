# https://github.com/NixOS/nixpkgs/issues/64344#issuecomment-745739682
{ stdenv
, lib
, fetchurl
, unzip
, addOpenGLRunpath
, ...
}:
stdenv.mkDerivation rec {
  name = "svpflow-${version}";
  version = "4.3.0.168";

  src = fetchurl {
    url = "https://www.svp-team.com/files/gpl/svpflow-${version}.zip";
    sha256 = "13px50ijrrv1v2cvzbsrfasdqsshx782fl3fhk67iwi86mpa0hpx";
  };

  nativeBuildInputs = [
    unzip
    addOpenGLRunpath
  ];

  sourceRoot = ".";

  buildInputs = [
  ];

  unpackPhase = ''
    unzip -j $src lib-linux?libsvpflow{1,2}_vs64.so
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib
    cp libsvpflow{1,2}_vs64.so $out/lib/
  '';

  preFixup =
    let
      libPath = lib.makeLibraryPath [
        stdenv.cc.cc.lib
      ];
    in
    ''
      patchelf --set-rpath "${libPath}" $out/lib/libsvpflow1_vs64.so
      patchelf --set-rpath "${libPath}" $out/lib/libsvpflow2_vs64.so
    '';

  postFixup = ''
    addOpenGLRunpath $out/lib/libsvpflow1_vs64.so
    addOpenGLRunpath $out/lib/libsvpflow2_vs64.so
  '';

  meta = with lib; {
    homepage = "https://svp-team.com/";
    description = "SmoothVideo Project - svpflow libraries";
    platforms = platforms.linux;
    maintainers = with maintainers; [ sinity ];
  };
}

