let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
  mkHome username {
    configs = cfgs:
      with cfgs; [
        (firefox {wayland = true;})
        direnv
        git
        mpv
        nix
        printer-4500
        zsh
        neovim
        eww
        gtk
        qt
        hyprland
        foot
        utility-gui
        utility-scripts
        utility-cli
        (ssh {username = "flafy";})
        # gnome
        # sway
        tofi
        bitwarden
        # betterdiscord
        discord-open-asar
        qutebrowser
        fonts

        bspwm
        alacritty
        keyboard-xserver
        picom
        mouse-g502-xserver
        rofi
      ];

    system = {
      pkgs,
      lib,
      ...
    }: {
      time.timeZone = "Israel";

      programs = {
        adb.enable = true;
        kdeconnect.enable = true;
      };
      services.xserver.displayManager.startx.enable = true;

      services.xserver.enable = true;
      services.xserver.autorun = false;

      # services.xserver.libinput = {
      #   enable = true;
      #   touchpad = {
      #     tapping = true;
      #   };
      # };
      services.upower.enable = true;
      services.getty.autologinUser = username;
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.hyprland-wrapped}/bin/hyprland";
            # if config.specialisation != {}
            # then "${pkgs.hyprland-wrapped}/bin/hyprland"
            # else "WLR_DRM_DEVICES=/dev/dri/card0 ${pkgs.hyprland-wrapped}/bin/hyprland";
            user = username;
          };
        };
      };
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

      xdg = {
        portal = {
          enable = true;
          extraPortals = with pkgs;
            lib.mkForce [
              xdg-desktop-portal-wlr
              # xdg-desktop-portal-gtk
            ];
        };
      };

      environment.systemPackages = with pkgs; [
        (retroarch.override {
          cores = [
            libretro.genesis-plus-gx
            # libretro.snes9x
            # libretro.beetle-psx-hw
          ];
        })
        libretro.genesis-plus-gx
        # libretro.snes9x
        # libretro.beetle-psx-hw
      ];
    };

    home = {
      pkgs,
      ...
    }: {
      home.file.".xinitrc".text = ''
        exec bspwm
      '';
      manual.manpages.enable = false;
      # wayland.windowManager.sway = {
      #   enable = true;
      #   extraOptions = [ "--unsupported-gpu" ];
      # };
      home.packages = with pkgs; [
        neovide
        prismlauncher
        element-desktop
        scrcpy
        # pavucontrol
        cp-maps
        webcord
        drm_info
        # mpvpaper
        # neovide
        # (patchDesktop pkgs.webcord "webcord" "^Exec=webcord" "Exec=nvidia-offload webcord -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder")
        # nix-alien
        # nix-index # not necessary, but recommended
        # nix-index-update
      ];

      home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
    };
  }
