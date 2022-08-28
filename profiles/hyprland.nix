let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
mkHome username {
  configs = [
    /direnv.nix
    /git.nix
    # /gnome.nix
    /mpv.nix
    /nix.nix
    /printer-4500.nix
    # /vscode.nix
    # /wine.nix
    /zsh.nix
    # /steam.nix
    # /mouse-g502-xserver.nix
    /neovim
    # /i3.nix
    # /alacritty.nix
    # /picom.nix
    # /keyboard/xserver.nix
    # /betterdiscord.nix
    /eww
    # /rofi
    /gtk.nix
    /hyprland.nix
    /foot.nix
    /chromium.nix
    /utility-software.nix
    /utility-scripts.nix
    /utility-cli.nix
  ];

  system = { pkgs, ... }: {
    time.timeZone = "Israel";

    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
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
      firefox
      qdirstat
      scrcpy
      pavucontrol
      mpvpaper
      webcord
      (
        patchDesktop pkgs.chromium "chromium-browser"
        "^Exec=chromium" "Exec=nvidia-offload chromium -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder"
      )
      # Wayland
      # (
      #   patchDesktop pkgs.firefox "firefox"
      #   "^Exec=firefox" "Exec=env MOZ_ENABLE_WAYLAND=1 nvidia-offload firefox"
      # )
      # XWayland
      (
        patchDesktop pkgs.firefox "firefox"
        "^Exec=firefox" "Exec=env GDK_BACKEND=x11 nvidia-offload firefox"
      )
      (patchDesktop pkgs.mpv-unwrapped "mpv" "^Exec=mpv" "Exec=nvidia-offload mpv")
      (patchDesktop pkgs.webcord "webcord" "^Exec=webcord" "Exec=nvidia-offload webcord -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder")
    ];

    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  });
}
