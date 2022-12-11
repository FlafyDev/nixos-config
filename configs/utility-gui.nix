{
  inputs = {
    nixpkgs-gimp.url = "github:jtojnar/nixpkgs/gimp-meson";
  };

  add = { nixpkgs-gimp, ... }: {
    overlays = _: [
      (_final: prev: let
        pkgs = import nixpkgs-gimp {
          inherit (prev) system;
        };
      in {
        gimp-dev = pkgs.gimp;
      })
    ];
  };

  configs = cfgs:
    with cfgs; [
      guifetch
      listen-blue
    ];

  home = {pkgs, ...}: {
    home.packages = with pkgs; [
      gnome.eog
      mate.engrampa
      cinnamon.nemo.out
      gnome.simple-scan
      gnome.evince
      gnome.gnome-system-monitor
      gnome.gnome-font-viewer
      libreoffice
      krita
      # gimp
      libsForQt5.kdenlive
      qbittorrent
      gparted
      qdirstat
      pavucontrol
      lxde.lxrandr
      obs-studio
      onlyoffice-bin
      gimp-dev
    ];
  };
}
