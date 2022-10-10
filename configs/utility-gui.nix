{
  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      gnome.eog
      gnome.nautilus
      gnome.file-roller
      gnome.simple-scan
      gnome.evince
      gnome.gnome-system-monitor
      gnome.gnome-font-viewer
      # libreoffice
      krita
      gimp
      libsForQt5.kdenlive
      qbittorrent
      gparted
      qdirstat
      pavucontrol
      lxde.lxrandr
      obs-studio
      onlyoffice-bin
      guifetch
    ];
  };
}
