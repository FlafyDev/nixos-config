let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
mkHome username {
  configs = [
    /direnv
    /git
    /gnome
    /mpv
    /nix
    /printer
    /vscode
    /wine
    /zsh
    /steam
    /mouse-g502
  ];

  system = { pkgs, ... }: {
    time.timeZone = "Israel";

    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
    };

    services.xserver.libinput = {
      enable = true;
      touchpad = {
        tapping = true;
      };
    };

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
  };

  home = ({ pkgs, ... }: {
    home.packages = with pkgs; [
      libreoffice
      syncplay
      qbittorrent
      discord 
      krita
      polymc
      element-desktop
      gimp
      libsForQt5.kdenlive
      libstrangle
      yt-dlp
      termusic
      godot
      guake
      gparted
      firefox
      gnome.eog
      gnome.nautilus
      gnome.file-roller
      chromium
      qdirstat
    ];
  });
}
