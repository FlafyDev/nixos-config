{
  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      gnome.eog
      gnome.nautilus
      gnome.file-roller
      gnome.simple-scan
      gnome.evince
      gnome.gnome-system-monitor
      libreoffice
      krita
      gimp
      libsForQt5.kdenlive
    ];
  };
}
