{
  buildNpmPackage,
  fetchFromGitHub,
  copyDesktopItems,
  python3,
  pipewire,
  libpulseaudio,
  lib,
  xdg-utils,
  electron_24-bin,
  makeDesktopItem,
}: let
  inherit (lib) makeLibraryPath;
in
  buildNpmPackage rec {
    pname = "webcord";
    version = "git-unstable";

    src = fetchFromGitHub {
      owner = "kakxem";
      repo = "WebCord";
      rev = "aea6bf7a121879e02d4723e860094aa2d36e2774";
      sha256 = "sha256-MTCP5aeSlZCIpt8Bscemo6Bs8bpfzE0QUzUmJD74+3g=";
    };

    npmDepsHash = "sha256-fLbNFysUrxvzj5eUVND5MlHfY0U4z16q+jx+yq1NATs=";

    nativeBuildInputs = [
      copyDesktopItems
      python3
      # swc
    ];

    libPath = makeLibraryPath [
      pipewire
      libpulseaudio
    ];

    # npm install will error when electron tries to download its binary
    # we don't need it anyways since we wrap the program with our nixpkgs electron
    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    # remove husky commit hooks, errors and aren't needed for packaging
    postPatch = ''
      rm -rf .husky
      find sources -type f -name "*.ts" -exec sed -i '1i // @ts-nocheck' {} \;
    '';

    # use swc instead of tsc for speed + no type errors
    # buildPhase = ''
    #   runHook preBuild
    #   ls -l
    #   # npx swc sources --out-dir app -C module.type=commonjs -D
    #   swc compile sources --out-dir app --config-json '{"module": {"type": "commonjs"}}' --copy-files
    #   runHook postBuild
    # '';
    # NODE_OPTIONS = "--skipLibCheck";
    patches = [
      #   # (pkgs.substituteAll {
      #   #   src = ./add-extension.patch;
      #   #   vencord = pkgs.vencord-web-extension;
      #   # })
      ./custom-build.patch
    ];

    # override installPhase so we can copy the only folders that matter
    # installPhase = ''
    #   runHook preInstall
    #
    #   mkdir -p $out/lib/node_modules/webcord
    #   mkdir -p $out/lib/node_modules/webcord/node_modules/node-pipewire
    #   cp -r app node_modules sources package.json $out/lib/node_modules/webcord/
    #   cp -r ${nodePipewire}/* $out/lib/node_modules/webcord/node_modules/node-pipewire/
    #
    #   install -Dm644 sources/assets/icons/app.png $out/share/icons/hicolor/256x256/apps/webcord.png
    #
    #   makeWrapper '${pkgs.electron_24}/bin/electron' $out/bin/webcord \
    #   --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/webcord \
    #   --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}}" \
    #   --add-flags $out/lib/node_modules/webcord/
    #
    #   runHook postInstall
    # '';
    # override installPhase so we can copy the only folders that matter

    installPhase = let
      libPath = lib.makeLibraryPath [
        libpulseaudio
        pipewire
      ];
      binPath = lib.makeBinPath [xdg-utils];
      nodePipewire = let
        nodePipewireVersion = "1.0.14";
      in
        builtins.fetchTarball {
          url = "https://github.com/kakxem/node-pipewire/releases/download/${nodePipewireVersion}/node-v108-linux-x64.tar.gz";
          sha256 = "046fhaqz06sdnvrmvq02i2k1klv90sgyz24iz3as0hmr6v90ldm1";
        };
    in ''
      runHook preInstall

      # Remove dev deps that aren't necessary for running the app
      npm prune --omit=dev

      mkdir -p $out/lib/node_modules/webcord
      mkdir -p $out/lib/node_modules/webcord/node_modules/node-pipewire
      cp -r app node_modules sources package.json $out/lib/node_modules/webcord/
      cp -r ${nodePipewire}/* $out/lib/node_modules/webcord/node_modules/node-pipewire/

      install -Dm644 sources/assets/icons/app.png $out/share/icons/hicolor/256x256/apps/webcord.png

      # Add xdg-utils to path via suffix, per PR #181171
      makeWrapper '${lib.getExe electron_24-bin}' $out/bin/webcord \
        --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/webcord \
        --suffix PATH : "${binPath}" \
        --add-flags "--ozone-platform-hint=auto" \
        --add-flags $out/lib/node_modules/webcord/

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "webcord";
        exec = "webcord";
        icon = "webcord";
        desktopName = "WebCord";
        comment = meta.description;
        categories = ["Network" "InstantMessaging"];
      })
    ];

    meta = with lib; {
      description = "A Discord and Fosscord electron-based client implemented without Discord API";
      homepage = "https://github.com/kakxem/WebCord/tree/feature/screenshare-with-audio";
      license = licenses.mit;
      maintainers = with maintainers; [huantian];
      platforms = electron_24-bin.meta.platforms;
    };
  }
