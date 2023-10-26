{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.games;
  inherit (lib) concatStringsSep mapAttrsToList;
  inherit (builtins) attrNames;
  bubbleWrapGame = pkgs.callPackage ./bubble-wrap-game.nix {};
in {
  options.games = {
    enable = mkEnableOption "games";
    autoLaunchSteam = {
      enable = mkEnableOption "autoLaunchSteam";
    };
  };

  config = mkIf cfg.enable {
    unfree.allowed = [
      "steam"
      "steam-original"
      "steam-run"
    ];
    nixpak.enable = true;
    os.nixpkgs.overlays = [
      (_final: prev: {
        srb2 = prev.srb2.overrideAttrs (old: {
          patches =
            old.patches
            ++ [
              ./srb2/ignore-cv-allow-lua.patch
            ];
        });
      })
    ];
    os.virtualisation.waydroid.enable = true;
    os.programs.gamemode.enable = true;
    os.programs.steam = {
      enable = true;
      # remotePlay.openFirewall = true;
      # dedicatedServer.openFirewall = true;
    };
    hm.wayland.windowManager.hyprland.settings.exec-once = mkIf cfg.autoLaunchSteam.enable [
      ''env DISPLAY=:${toString config.display.hyprland.headlessXorg.num} steam -login flafythrow $(get-password "flafythrow steam")''
    ];

    hm.xdg.configFile."retroarch/retroarch.cfg".source = ./retroarch.cfg;

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
          # Undertale
          ''~/Games/wine-prefixes/undertale/drive_c/users/flafy/AppData/Local/UNDERTALE''
          # Sonic Robo Blast 2
          ''~/.srb2/addons''
          ''~/.srb2/autoexec.cfg''
          ''~/.srb2/config.cfg''
          ''~/.srb2/custom_gamedata.dat''
          ''~/.srb2/custom_gamedata1.ssg''
          ''~/.srb2/gamedata.dat''
          ''~/.srb2/srb2sav1.ssg''
          # TheXTech SMBX
          ''~/Games/data/windows/thextech-smbx/settings''
          # Pokemon Fire Red
          ''~/.config/retroarch/saves/Pokemon\ -\ Fire\ Red\ Version\ \(U\)\ \(V1.1\).srm''
          # Baldur's Gate 3
          ''~/Games/wine-prefixes/baldurs-gate-3/pfx/drive_c/users/Public/Documents/OnlineFix/1086940''
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
          ${pkgs.restic}/bin/restic backup ${concatStringsSep " " savefiles} --repo sftp:server@mera:backups/game-saves \
              --password-command "get-password restic-game-saves"

          sudo umount /mnt/winvm
          sudo ${pkgs.qemu}/bin/qemu-nbd --disconnect /dev/nbd0
          sudo rmmod nbd
        '';

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
          undertale = bubbleWrapGame {
            data = "windows/undertale";
            winePrefix = "undertale";
            script = {data, ...}: ''
              env -C ${data} wine UNDERTALE.exe
            '';
            pathPackages = [pkgs.wine];
          };
          smbx = bubbleWrapGame {
            data = "windows/thextech-smbx";
            winePrefix = "thextech-smbx";
            script = {data, ...}: ''
              unset SDL_VIDEODRIVER
              unset SDL_AUDIODRIVER
              env -C ${data} wine64 smbx-win64.exe
            '';
            pathPackages = [pkgs.wine64];
          };
          pkmn-fire-red = bubbleWrapGame {
            data = "roms/gba/pokemon-fire-red";
            script = {data, ...}: ''
              retroarch -L mgba ${data}/*.gba  # Using * to avoid writing the filename.
            '';
            preScript = ''
              mkdir -p ~/.config/retroarch
            '';
            extraRW = {
              envSuffix,
              sloth,
            }: [
              (sloth.concat' sloth.homeDir ''/.config/retroarch'')
            ];
            pathPackages = [pkgs.retroarchFull];
          };
          srb2 = bubbleWrapGame {
            script = _: ''
              ${pkgs.srb2}/bin/srb2
            '';
            preScript = ''
              mkdir -p ~/.srb2
            '';
            extraRW = {
              envSuffix,
              sloth,
            }: [
              (sloth.concat' sloth.homeDir ''/.srb2'')
            ];
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
          baldurs-gate-3 = bubbleWrapGame {
            data = "windows/baldurs-gate-3";
            winePrefix = "baldurs-gate-3";
            dontWrap = true;
            script = {data}: ''
              unset SDL_VIDEODRIVER
              export WINEDLLOVERRIDES="OnlineFix64=n;SteamOverlay64=n;winmm=n,b;dnet=n;steam_api64=n;winhttp.dll=n,b"
              export STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.local/share/Steam/
              export STEAM_COMPAT_DATA_PATH=$WINEPREFIX
              env -C ${data}/bin steam-run ~/.local/share/Steam/steamapps/common/Proton\ -\ Experimental/proton run bg3.exe
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
          valheim = bubbleWrapGame {
            data = "windows/valheim";
            winePrefix = "valheim";
            script = {data}: ''
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
          spelunky-2 = bubbleWrapGame {
            data = "windows/spelunky-2";
            winePrefix = "spelunky-2";
            script = {data}: ''
              export WINEDLLOVERRIDES="OnlineFix64=n;SteamOverlay64=n;winmm=n,b;dnet=n;steam_api64=n;winhttp.dll=n,b"
              export STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.local/share/Steam/
              export STEAM_COMPAT_DATA_PATH=$WINEPREFIX
              env -C ${data} steam-run ~/.local/share/Steam/steamapps/common/Proton\ -\ Experimental/proton run Spel2.exe
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
              *)
                  echo "Invalid input. Usage: launch-game [${concatStringsSep " | " (attrNames games)}]"
                  exit 1
                  ;;
          esac
        '';
    in [
      backup-game-saves
      launch-game
      pkgs.retroarchFull
    ];
  };
}
