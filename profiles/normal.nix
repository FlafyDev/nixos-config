let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
mkHome username {
  system = { config, lib, pkgs, ... }: {
    imports = [
      ../system-configs/home-printer.nix
      ../system-configs/gnome-xserver.nix
    ];

    time.timeZone = "Israel";

    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
    };

    services.xserver.libinput = {
      enable = true;
      mouse = {
        accelSpeed = "-0.78";
        accelProfile = "flat";
      };
    };

    users.defaultUserShell = pkgs.zsh;

    environment.pathsToLink = [ "/share/zsh" ];

    environment.systemPackages = with pkgs; [
      nano
      wget
      parted
      git
      neofetch
      unzip
      gh
      xclip
    ];
  };

  home = ({ config, lib, pkgs, ... }: {
    imports = [
      ../home-configs/git.nix
      ../home-configs/gnome.nix 
      ../home-configs/mpv.nix
      ../home-configs/vscode.nix
      ../home-configs/direnv.nix
      ../home-configs/zsh.nix
    ];

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
      mate.engrampa
      chromium
    ];

    home.stateVersion = "21.11";
  });
}
