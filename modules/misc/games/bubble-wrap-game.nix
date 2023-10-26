{
  writeShellScriptBin,
  lib,
  coreutils-full,
  mkNixPak,
}: let
  inherit (lib) makeBinPath optional;
in
  {
    data ? null,
    winePrefix ? null,
    pathPackages ? [],
    script,
    extraRW ? _: [],
    extraRO ? _: [],
    dontWrap ? false, # A giveup flag
    preScript ? "",
    networking ? false,
  }: let
    scriptPackage = writeShellScriptBin "game" ''
      export PATH=''$PATH:${makeBinPath (pathPackages ++ [coreutils-full])}
      ${script {
        data =
          if data != null
          then "~/Games/data/${data}"
          else null;
      }}
    '';
    sandboxedPackage =
      (mkNixPak {
        config = {sloth, ...}: {
          app = {
            package = scriptPackage;
            binPath = "bin/game";
          };

          # flatpak.appId = "org.mozilla.Firefox";

          gpu.enable = true;
          gpu.provider = "bundle";
          fonts.enable = true;
          locale.enable = true;

          etc.sslCertificates.enable = networking;

          bubblewrap = let
            envSuffix = envKey: sloth.concat' (sloth.env envKey);
          in {
            network = networking;

            bind.rw =
              [
                (sloth.concat' sloth.xdgCacheHome "/fontconfig")
                (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
                (envSuffix "XDG_RUNTIME_DIR" "/doc")
                (envSuffix "XDG_RUNTIME_DIR" "/dconf")
                (sloth.concat [
                  (sloth.env "XDG_RUNTIME_DIR")
                  "/"
                  (sloth.env "WAYLAND_DISPLAY")
                ])
                (envSuffix "XDG_RUNTIME_DIR" "/at-spi/bus")
                (envSuffix "XDG_RUNTIME_DIR" "/gvfsd")
                (envSuffix "XDG_RUNTIME_DIR" "/pulse")
                (envSuffix "XDG_RUNTIME_DIR" "/pipewire-0")

                # (envSuffix "XDG_RUNTIME_DIR" "/")
                "/tmp/.wine-1000"

                "/var/lib/alsa"
                "/proc/asound"
              ]
              ++ (optional (data != null) (sloth.concat' sloth.homeDir "/Games/data/${data}"))
              ++ (optional (winePrefix != null) (sloth.concat' sloth.homeDir "/Games/wine-prefixes/${winePrefix}"))
              ++ (extraRW {inherit envSuffix sloth;});

            bind.ro =
              [
                (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
                "/etc/X11"
                "/tmp/.X11-unix/X0"
                "/run/opengl-driver"
                "/run/opengl-driver-32"
                "/etc/resolv.conf"
                "/etc/localtime"
                "/sys/bus/pci"
              ]
              ++ (extraRO {inherit envSuffix sloth;});

            bind.dev = [
              "/dev/snd"
              "/dev/input"
            ];

            env = {};
          };
        };
      })
      .config
      .env;
  in
    # Wrapper
    writeShellScriptBin "game" ''
      ${
        if winePrefix != null
        then ''
          export WINEPREFIX=~/Games/wine-prefixes/${winePrefix}
          ${coreutils-full}/bin/mkdir -p $WINEPREFIX
        ''
        else ""
      }
      export PATH=''$PATH:${lib.makeBinPath (pathPackages ++ [coreutils-full])}
      ${preScript}
      ${
        if dontWrap
        then scriptPackage
        else sandboxedPackage
      }/bin/game
    ''
