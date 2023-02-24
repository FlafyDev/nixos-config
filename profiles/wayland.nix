let
  mkSystem = import ../utils/mk-system.nix;
  username = "flafydev";
in
  mkSystem {
    inherit username;
    args = {
      # theme = "Halloween";
      theme = "";
    };
  } {
    configs = cfgs:
      with cfgs; [
        (firefox {wayland = true;})
        # steam
        helix
        (greetd username)
        kmonad
        direnv
        git
        mpv
        nix
        printer-4500
        zsh
        starship
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
        sway
        tofi
        bitwarden
        # betterdiscord
        # discord-open-asar
        qutebrowser
        chromium
        fonts
        bspwm
        alacritty
        # keyboard-xserver
        picom
        mouse-g502-xserver
        rofi
        wine
        assets
        # waydroid
        deluge
      ];

    system = {
      pkgs,
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
      # services.getty.autologinUser = username;

      virtualisation.docker.enable = true;

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

      environment.systemPackages = with pkgs; [
        distrobox
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

    home = {pkgs, ...}: {
      home.file.".xinitrc".text = ''
        exec bspwm
      '';
      manual.manpages.enable = false;
      # wayland.windowManager.sway = {
      #   enable = true;
      #   extraOptions = [ "--unsupported-gpu" ];
      # };
      home.packages = with pkgs; [
        lutris
        android-studio
        prismlauncher
        element-desktop
        scrcpy
        # pavucontrol
        cp-maps
        # webcord
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
