{
  add = { nixpkgs, ... }: {
    overlays = _: [
      (_final: prev: {
        discord-open-asar = with prev; (let
          binaryName = "DiscordCanary";

          disableBreakingUpdates =
            runCommand "disable-breaking-updates.py"
            {
              pythonInterpreter = "${python3.interpreter}";
              configDirName = lib.toLower binaryName;
            } ''
              mkdir -p $out/bin
              cp "${nixpkgs}/pkgs/applications/networking/instant-messengers/discord/disable-breaking-updates.py" $out/bin/disable-breaking-updates.py
              substituteAllInPlace $out/bin/disable-breaking-updates.py
              chmod +x $out/bin/disable-breaking-updates.py
            '';
        in (discord-canary.override {
            nss = pkgs.nss_latest;
            withOpenASAR = true;
          })
          .overrideAttrs (old: rec {
            libPath = old.libPath + ":${libglvnd}/lib";

            installPhase = ''
              runHook preInstall

              mkdir -p $out/{bin,opt/${binaryName},share/pixmaps,share/icons/hicolor/256x256/apps}
              mv * $out/opt/${binaryName}

              chmod +x $out/opt/${binaryName}/${binaryName}
              patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
                  $out/opt/${binaryName}/${binaryName}

              wrapProgramShell $out/opt/${binaryName}/${binaryName} \
                  "''${gappsWrapperArgs[@]}" \
                  --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
                  --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
                  --prefix LD_LIBRARY_PATH : ${libPath}:$out/opt/${binaryName} \
                  --run "${lib.getExe disableBreakingUpdates}"

              ln -s $out/opt/${binaryName}/${binaryName} $out/bin/
              # Without || true the install would fail on case-insensitive filesystems
              ln -s $out/opt/${binaryName}/${binaryName} $out/bin/${
                lib.strings.toLower binaryName
              } || true

              ln -s $out/opt/${binaryName}/discord.png $out/share/pixmaps/${old.pname}.png
              ln -s $out/opt/${binaryName}/discord.png $out/share/icons/hicolor/256x256/apps/${old.pname}.png

              ln -s "${old.desktopItem}/share/applications" $out/share/

              runHook postInstall
            '';
          }));
      })
    ];
  };

  home = {pkgs, ...}: {
    home.packages = [pkgs.discord-open-asar];

    xdg.configFile."discord/settings.json".text = builtins.toJSON {
      openasar = {
        setup = true;
        quickstart = true;
        noTyping = true;
        cmdPreset = "none";
        # css = builtins.readFile ../betterdiscord/themes/frosted-glass-blue/FrostedGlassBlue.theme.css;
      };
      cmdPreset = "none";
      IS_MAXIMIZED = false;
      IS_MINIMIZED = false;
      WINDOW_BOUNDS = {
        x = 563;
        y = 100;
        width = 1314;
        height = 967;
      };
      trayBalloonShown = true;
      # Why such a scary name for just enabling devtools?
      # Perhaps I don't know what I'm doing??
      DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
    };
  };
}
