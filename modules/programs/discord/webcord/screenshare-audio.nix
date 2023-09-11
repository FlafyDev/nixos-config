{pkgs, ...}:
pkgs.buildNpmPackage rec {
  pname = "webcord";
  version = "git-unstable";
  nodePipewireVersion = "1.0.14";

  src = pkgs.fetchFromGitHub {
    owner = "kakxem";
    repo = "WebCord";
    rev = "35d6b71cf9fa49de29c1281c8edde0e80f2b816e";
    sha256 = "sha256-apbGUIDEpkjauW6JLUUAR9K9DP3O1ZH/MKQtO1NmMSI=";
  };
  npmDepsHash = "sha256-G5VENikU/Anbe1unzNtzkIaJ5Z+gsYyqwdweMyuO1j4=";

  nativeBuildInputs = [
    pkgs.copyDesktopItems
    pkgs.python3
  ];

  libPath = pkgs.lib.makeLibraryPath [
    pkgs.pipewire
    pkgs.libpulseaudio
  ];

  # npm install will error when electron tries to download its binary
  # we don't need it anyways since we wrap the program with our nixpkgs electron
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # remove husky commit hooks, errors and aren't needed for packaging
  postPatch = ''
    rm -rf .husky
  '';

  # use swc instead of tsc for speed + no type errors
  buildPhase = ''
    runHook preBuild
    npx swc sources --out-dir app -C module.type=commonjs -D
    runHook postBuild
  '';

  patches = [
    # (pkgs.substituteAll {
    #   src = ./add-extension.patch;
    #   vencord = pkgs.vencord-web-extension;
    # })
    ./custom-build.patch
  ];

  nodePipewire = builtins.fetchTarball {
    url = "https://github.com/kakxem/node-pipewire/releases/download/${nodePipewireVersion}/node-v108-linux-x64.tar.gz";
    sha256 = "046fhaqz06sdnvrmvq02i2k1klv90sgyz24iz3as0hmr6v90ldm1";
  };

  # override installPhase so we can copy the only folders that matter
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/webcord
    mkdir -p $out/lib/node_modules/webcord/node_modules/node-pipewire
    cp -r app node_modules sources package.json $out/lib/node_modules/webcord/
    cp -r ${nodePipewire}/* $out/lib/node_modules/webcord/node_modules/node-pipewire/

    install -Dm644 sources/assets/icons/app.png $out/share/icons/hicolor/256x256/apps/webcord.png

    makeWrapper '${pkgs.electron_24}/bin/electron' $out/bin/webcord \
    --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/webcord \
    --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}" \
    --add-flags $out/lib/node_modules/webcord/

    runHook postInstall
  '';

  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "webcord";
      exec = "webcord";
      icon = "webcord";
      desktopName = "WebCord";
      comment = meta.description;
      categories = ["Network" "InstantMessaging"];
    })
  ];

  meta = with pkgs.lib; {
    description = "A Discord and Fosscord electron-based client implemented without Discord API";
    homepage = "https://github.com/kakxem/WebCord/tree/feature/screenshare-with-audio";
    license = licenses.mit;
    maintainers = with maintainers; [huantian];
    platforms = pkgs.electron_24.meta.platforms;
  };
}
