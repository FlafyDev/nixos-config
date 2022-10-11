let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
mkHome username {
  configs = cfgs: with cfgs; [
    ( firefox { wayland = true; } )
    direnv
    git
    mpv
    nix
    printer-4500
    zsh
    neovim
    ( eww { wayland = true; } )
    gtk
    qt
    hyprland
    foot
    utility-gui
    utility-scripts
    utility-cli
    ssh
    gnome
    alacritty
    keyboard-xserver
    bitwarden
    # sway
    tofi
    # betterdiscord
    discord-open-asar
    qutebrowser
  ];

  system = { pkgs, lib, ... }: {
    time.timeZone = "Israel";

    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
    };

    # services.xserver.enable = true;

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


    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; lib.mkForce [
          xdg-desktop-portal-wlr
        ];
      };
    };

    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [
        "AurulentSansMono"
        "JetBrainsMono"
        "FiraCode"
        "DroidSansMono"
      ]; })
      source-sans
      cantarell-fonts
      dejavu_fonts
      source-code-pro # Default monospace font in 3.32
      source-sans
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];
  };

  home = ({ pkgs, lib, inputs, ... }: {
    home.packages = with pkgs; [
      polymc
      element-desktop
      # scrcpy
      # pavucontrol
      webcord
      mpvpaper
      # neovide
      # (patchDesktop pkgs.webcord "webcord" "^Exec=webcord" "Exec=nvidia-offload webcord -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder")
    ];

    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  });
}
