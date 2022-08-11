let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
mkHome username {
  configs = [
    /direnv.nix
    /git.nix
    /gnome.nix
    /mpv.nix
    /nix.nix
    /printer-4500.nix
    /vscode.nix
    /wine.nix
    /zsh.nix
    /steam.nix
    /mouse-g502.nix
    /neovim
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

    programs.betterdiscord = {
      enable = true;
    };
  });
}
