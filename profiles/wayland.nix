let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
mkHome username {
  configs = cfgs: with cfgs; [
    ( firefox { wayland = true; } )
    direnv
    git
    # gnome
    mpv
    nix
    printer-4500
    # vscode
    # wine
    zsh
    # steam
    # mouse-g502-xserver
    neovim
    # i3
    # alacritty
    # picom
    # keyboard/xserver
    # betterdiscord
    ( eww { wayland = true; } )
    # rofi
    gtk
    hyprland
    foot
    chromium
    utility-software
    utility-scripts
    utility-cli
  ];

  system = { pkgs, ... }: {
    time.timeZone = "Israel";

    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
    };

    services.xserver.enable = true;

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


    # xdg = {
    #   portal = {
    #     enable = true;
    #     extraPortals = with pkgs; [
    #       xdg-desktop-portal-wlr
    #       xdg-desktop-portal-gtk
    #     ];
    #   };
    # };

    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
  };

  home = ({ pkgs, lib, inputs, ... }: let 
    patchDesktop = pkg: appName: from: to: lib.hiPrio (pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
      ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
      ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
    '');
  in {
    home.packages = with pkgs; [
      qbittorrent
      polymc
      element-desktop
      gparted
      qdirstat
      scrcpy
      pavucontrol
      # webcord
      mpvpaper
      (
        patchDesktop pkgs.chromium "chromium-browser"
        "^Exec=chromium" "Exec=nvidia-offload chromium -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder"
      )
      (patchDesktop pkgs.mpv-unwrapped "mpv" "^Exec=mpv" "Exec=nvidia-offload mpv")
      # (patchDesktop pkgs.webcord "webcord" "^Exec=webcord" "Exec=nvidia-offload webcord -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder")
    ];

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      XDG_CURRENT_DESKTOP = "sway"; 
    };

    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  });
}
