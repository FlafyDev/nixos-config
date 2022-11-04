let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
  mkHome username {
    configs = cfgs:
      with cfgs; [
        direnv
        git
        mpv
        nix
        printer-4500
        # vscode
        zsh
        mouse-g502-xserver
        neovim
        # i3
        bspwm
        alacritty
        picom
        keyboard-xserver
        eww
        rofi
        bitwarden
        gtk
        qt
        utility-gui
        utility-scripts
        utility-cli
        (ssh {username = "flafy";})
        (firefox {wayland = false;})
        # chromium
        # neofetch
        # kitty
        discord-open-asar
        qutebrowser
        fonts
      ];

    system = {pkgs, ...}: {
      time.timeZone = "Israel";

      programs = {
        adb.enable = true;
        kdeconnect.enable = true;
      };

      services.xserver.desktopManager.autoLogin = {
        enable = true;
        user = username;
      };

      # services.xserver.libinput = {
      #   enable = true;
      #   touchpad = {
      #     tapping = true;
      #   };
      # };
      services.upower.enable = true;
      # services.tlp.enable = true;
      # Notify on low battery
      # systemd.user.services.batsignal = {
      #   Install.WantedBy = [ "graphical-session.target" ];
      #   Unit = {
      #     Description = "Battery status daemon";
      #     PartOf = [ "graphical-session.target" ];
      #   };
      #   Service = {
      #     Type = "simple";
      #     ExecStart = "${pkgs.batsignal}/bin/batsignal";
      #   };
      # };
    };

    home = {
      pkgs,
      lib,
      inputs,
      ...
    }: {
      home.packages = with pkgs; [
        prismlauncher
        element-desktop
        scrcpy
        cp-maps
        # (patchDesktop pkgs.mpv-unwrapped "mpv" "^Exec=mpv" "Exec=nvidia-offload mpv")
        libva-utils
      ];

      home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
    };
  }
