{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.games;
  inherit (lib) optional optionalString concatStringsSep mapAttrsToList;

  bubbleWrapGame = {
    data,
    winePrefix ? null,
    pathPackages ? [],
    script,
    extraRW ? _: [],
    extraRO ? _: [],
    preScript ? "",
    networking ? false,
  }: let
    gamePackage =
      (pkgs.mkNixPak {
        config = {sloth, ...}: rec {
          app = {
            package = pkgs.writeShellScriptBin "game" ''
              export PATH=''$PATH:${lib.makeBinPath (pathPackages ++ [pkgs.coreutils-full])}
              ${script {
                data = "~/Games/data/${data}";
              }}
            '';
            binPath = "bin/game";
          };

          flatpak.appId = "org.mozilla.Firefox";

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

                (sloth.concat' sloth.homeDir "/Games/data/${data}")
                # (envSuffix "XDG_RUNTIME_DIR" "/")
                "/tmp/.wine-1000"

                "/var/lib/alsa"
                "/proc/asound"
              ]
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
            ];

            env = {};
          };
        };
      })
      .config
      .env;
  in
    pkgs.writeShellScriptBin "game" ''
      ${
        if winePrefix != null
        then ''
          export WINEPREFIX=~/Games/wine-prefixes/${winePrefix}
          ${pkgs.coreutils-full}/bin/mkdir -p $WINEPREFIX
        ''
        else ""
      }
      export PATH=''$PATH:${lib.makeBinPath (pathPackages ++ [pkgs.coreutils-full])}
      ${preScript}
      ${gamePackage}/bin/game
    '';
in {
  options.games = {
    enable = mkEnableOption "games";
  };

  config = mkIf cfg.enable {
    unfree.allowed = [
      "steam"
      "steam-original"
      "steam-run"
    ];
    nixpak.enable = true;
    os.virtualisation.waydroid.enable = true;
    os.programs.gamemode.enable = true;
    os.programs.steam = {
      enable = true;
      # remotePlay.openFirewall = true;
      # dedicatedServer.openFirewall = true;
    };
    os.environment.systemPackages = let
      backup-game-saves = let
        savefiles = [
          # Borderlands 3 (no idea why it's inside OneDrive)
          ''/mnt/winvm/Users/flafy/OneDrive/Documents/My\ Games/Borderlands\ 3/Saved/SaveGames''
          # Valheim
          ''~/Games/wine-prefixes/valheim/pfx/drive_c/users/Public/Documents/OnlineFix/892970/Saves''
          # Shovel Knight
          ''~/.local/share/Yacht\ Club\ Games/Shovel\ Knight''
          # Spelunky 2
          ''~/Games/data/windows/spelunky-2/input.cfg''
          ''~/Games/data/windows/spelunky-2/savegame.sav''
          ''~/Games/data/windows/spelunky-2/settings.cfg''
          ''~/Games/data/windows/spelunky-2/local.cfg''
          # Sonic Mania
          ''~/Games/wine-prefixes/sonic-mania/drive_c/users/Public/Documents/Steam/CODEX/584400/remote/savedata.bin''
          ''~/Games/data/windows/sonic-mania/Settings.ini''
          # Hollow Knight
          ''~/.config/unity3d/Team\ Cherry/Hollow\ Knight''
        ];
      in
        pkgs.writeShellScriptBin "backup-game-saves" ''
          # TODO: Don't hardcode VM stuff
          echo "Binding Windows VM disk image"

          if mount | grep -q '/dev/nbd0p3 on /mnt/winvm'; then
              echo "Disk is already mounted, skipping mount operation."
          else
              sudo modprobe nbd max_part=8
              sudo ${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 /var/lib/libvirt/images/win10-new2.qcow2

              # Check the exit status of the qemu-nbd command
              if [ $? -ne 0 ]; then
                  echo "qemu-nbd command failed, skipping Windows games backup. Windows VM is probably running."
                  sudo rmmod nbd
                  exit 1
              else
                  sudo mkdir -p /mnt/winvm
                  # fdisk /dev/nbd0 -l
                  sudo mount /dev/nbd0p3 /mnt/winvm
              fi
          fi

          echo "Backuping up savefiles"
          # TODO: Don't hardcode sftp server.
          # TODO: Declarative password
          ${pkgs.restic}/bin/restic backup ${concatStringsSep " " savefiles} -r sftp:server@mera:backups/game-saves

          sleep 1
          sudo umount /mnt/winvm
          sleep 1
          sudo ${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 /var/lib/libvirt/images/win10-new2.qcow2
          sudo rmmod nbd
        '';

      # test-sonic-mania = bubbleWrapGame {
      #   script = ''
      #     mkdir -p ~/Games/wine-prefixes
      #     export WINEPREFIX=~/Games/wine-prefixes/sonic-mania
      #     env -C ~/Games/data/windows/sonic-mania ${pkgs.wine}/bin/wine SonicMania.exe
      #   '';
      #   pathPackages = [pkgs.coreutils-full];
      # };
      # test-sonic-mania = pkgs.writeShellScriptBin "sonic-mania" ''
      #   ${pkgs.coreutils-full}/bin/echo $DISPLAY
      #   ${pkgs.coreutils-full}/bin/mkdir -p ~/Games/wine-prefixes
      #   export WINEPREFIX=~/Games/wine-prefixes/sonic-mania
      #   ${pkgs.coreutils-full}/bin/env -C ~/Games/data/windows/sonic-mania ${pkgs.wine}/bin/wine SonicMania.exe
      # '';

      launch-game = let
        games = {
          sonic-mania = bubbleWrapGame {
            data = "windows/sonic-mania";
            winePrefix = "sonic-mania";
            script = {data, ...}: ''
              env -C ${data} wine SonicMania.exe
            '';
            pathPackages = [pkgs.wine];
          };
          shovel-knight = bubbleWrapGame {
            data = "linux/shovel-knight";
            script = {data, ...}: ''
              export SDL_VIDEODRIVER=x11
              export SDL_AUDIODRIVER=pulseaudio
              export LD_PRELOAD="${pkgs.SDL2}/lib/libSDL2-2.0.so.0"
              steam-run ${data}/start.sh
            '';
            pathPackages = [pkgs.steam-run];
            extraRW = {
              envSuffix,
              sloth,
            }: [
              (sloth.concat' sloth.homeDir ''/.local/share/Yacht Club Games'')
            ];
          };
          hollow-knight = bubbleWrapGame {
            data = "linux/hollow-knight";
            script = {data, ...}: ''
              export SDL_VIDEODRIVER=x11
              export SDL_AUDIODRIVER=pulseaudio
              export LD_PRELOAD="${pkgs.SDL2}/lib/libSDL2-2.0.so.0"
              steam-run ${data}/start.sh
            '';
            pathPackages = [pkgs.steam-run];
            preScript = ''
              mkdir -p ~/.config/unity3d/Team\ Cherry/Hollow\ Knight
            '';
            extraRW = {
              envSuffix,
              sloth,
            }: [
              (sloth.concat' sloth.homeDir ''/.config/unity3d/Team Cherry/Hollow Knight'')
            ];
          };
          # Requires steam running
          valheim = bubbleWrapGame {
            data = "windows/valheim";
            winePrefix = "valheim";
            script = {data}: ''
              mkdir -p $WINEPREFIX
              export WINEDLLOVERRIDES="OnlineFix64=n;SteamOverlay64=n;winmm=n,b;dnet=n;steam_api64=n;winhttp.dll=n,b"
              export STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.local/share/Steam/
              export STEAM_COMPAT_DATA_PATH=$WINEPREFIX
              env -C ${data} steam-run ~/.local/share/Steam/steamapps/common/Proton\ -\ Experimental/proton run valheim.exe
            '';
            pathPackages = [pkgs.steam-run];
            networking = true;
            extraRW = {
              envSuffix,
              sloth,
            }: [
              (sloth.concat' sloth.homeDir ''/.local/share/Steam'')
              (sloth.concat' sloth.homeDir ''/.steam'')
            ];
          };
        };
      in
        pkgs.writeShellScriptBin "launch-game" ''
          mkdir -p ~/Games/wine-prefixes

          case "$1" in
              ${concatStringsSep "\n" (mapAttrsToList (name: value: ''
              "${name}")
                ${value}/bin/game
                ;;
            '')
            games)}

              # "valheim")
              #     # Requires steam running
              #     mkdir -p ~/Games/wine-prefixes/valheim
              #     export WINEDLLOVERRIDES="OnlineFix64=n;SteamOverlay64=n;winmm=n,b;dnet=n;steam_api64=n;winhttp.dll=n,b"
              #     export STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.local/share/Steam/
              #     export STEAM_COMPAT_DATA_PATH=~/Games/wine-prefixes/valheim offload-gpu
              #     env -C ~/Games/data/windows/valheim steam-run ~/.local/share/Steam/steamapps/common/Proton\ -\ Experimental/proton run valheim.exe
              #     ;;
              "spelunky-2")
                  # will require steam running
                  # mkdir -p ~/Games/wine-prefixes/valheim
                  # WINEDLLOVERRIDES="OnlineFix64=n;SteamOverlay64=n;winmm=n,b;dnet=n;steam_api64=n;winhttp.dll=n,b" STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.local/share/Steam/ STEAM_COMPAT_DATA_PATH=~/Games/wine-prefixes/valheim offload-gpu env -C ~/Games/data/windows/valheim steam-run ~/.local/share/Steam/steamapps/common/Proton\ -\ Experimental/proton run valheim.exe
                  ;;
              # "shovel-knight")
              #     export SDL_VIDEODRIVER=x11
              #     export LD_PRELOAD="${pkgs.SDL2}/lib/libSDL2-2.0.so.0"
              #     steam-run ~/Games/data/linux/shovel-knight/start.sh
              #     ;;
              # "sonic-mania")
              #     mkdir -p ~/Games/wine-prefixes
              #     export WINEPREFIX=~/Games/wine-prefixes/sonic-mania
              #     env -C ~/Games/data/windows/sonic-mania ${pkgs.wine}/bin/wine SonicMania.exe
              #     ;;
              *)
                  echo "Invalid input. Usage: $0 <game>"
                  exit 1
                  ;;
          esac
        '';
      # TODO: scrap this idea of copying. just do: restic backup <paths>
      # backup-game-saves = pkgs.writeShellScriptBin "backup-game-saves" (''
      #     echo "## Copying Linux savefiles"
      #     export SAVES=~/Games/saves
      #
      #     echo "Copying Valheim savefiles"
      #     mkdir -p $SAVES/valheim
      #     cp -r ~/Games/wine-prefixes/valheim/pfx/drive_c/users/Public/Documents/OnlineFix/892970/Saves $SAVES/valheim
      #
      #     echo "Copying Spelunky 2 savefiles"
      #     mkdir -p $SAVES/spelunky-2
      #     # TODO: copy
      #
      #     echo "Copying Shovel Knight savefiles"
      #     mkdir -p $SAVES/shovel-knight
      #     cp -r ~/.local/share/Yacht\ Club\ Games/Shovel\ Knight $SAVES/shovel-knight
      #   ''
      #   # TODO: Don't hardcode VM stuff
      #   + (optionalString true ''
      #     echo "## Copying Windows savefiles"
      #
      #     sudo modprobe nbd max_part=8
      #     sudo ${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 /var/lib/libvirt/images/win10-new2.qcow2
      #
      #     # Check the exit status of the qemu-nbd command
      #     if [ $? -ne 0 ]; then
      #         echo "qemu-nbd command failed, skipping Windows games backup. Windows VM is probably running."
      #     else
      #       sudo mkdir -p /mnt/winvm
      #       # fdisk /dev/nbd0 -l
      #       sudo mount /dev/nbd0p3 /mnt/winvm
      #
      #       echo "Copying Borderlands 3 savefiles"
      #       mkdir -p $SAVES/borderlands-3
      #       cp -r /mnt/winvm/Users/flafy/OneDrive/Documents/My\ Games/Borderlands\ 3/Saved $SAVES/borderlands-3
      #
      #       sudo umount /mnt/winvm
      #       sudo ${pkgs.qemu}/bin/qemu-nbd --connect=/dev/nbd0 /var/lib/libvirt/images/win10-new2.qcow2
      #     fi
      #
      #     sudo rmmod nbd
      #   '')
      #   + ''
      #     echo "## Backing up savefiles"
      #
      #     # TODO: Don't hardcode sftp server.
      #     # TODO: Declarative password
      #     ${pkgs.restic}/bin/restic backup ~/Games/saves -r sftp:server@10.0.0.41:backups/game-saves
      #   '');
    in [
      backup-game-saves
      launch-game
    ];
  };
}
