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
    /wine.nix
    /zsh.nix
    /steam.nix
    # /mouse-g502-xserver.nix
    /neovim
    # /i3.nix
    # /alacritty.nix
    # /picom.nix
    # /keyboard/xserver.nix
    # /betterdiscord.nix
    /eww
    /rofi
    /gtk.nix
    /utility-software.nix
    /hyprland.nix
    /foot.nix
    /utility-scripts.nix
    /chromium.nix
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

    environment.systemPackages = with pkgs; [
      nano
      wget
      parted
      git
      neofetch
      unzip
      gh
      xclip
      service-wrapper
    ];

    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
  };

  home = ({ pkgs, lib, inputs, ... }: {
    home.packages = with pkgs; [
      syncplay
      qbittorrent
      polymc
      element-desktop
      libstrangle
      yt-dlp
      termusic
      godot
      guake
      gparted
      firefox
      qdirstat
      htop
      scrcpy
      pavucontrol
      kitty
      mpvpaper
      webcord
    ];

    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  });
}
