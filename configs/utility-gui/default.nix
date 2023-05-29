{
  inputs = {
    nixpkgs-gimp.url = "github:jtojnar/nixpkgs/gimp-meson";
    guifetch.url = "github:flafydev/guifetch";
    listen-blue.url = "github:flafydev/listen_blue";
  };

  add = {
    nixpkgs-gimp,
    guifetch,
    listen-blue,
    ...
  }: {
    overlays = _: [
      guifetch.overlays.default
      listen-blue.overlays.default
      (_final: prev: let
        pkgs = import nixpkgs-gimp {
          inherit (prev) system;
        };
      in {
        gimp-dev = pkgs.gimp;
        # TODO: remove after updating nixpkgs
        syncplay = prev.syncplay.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [prev.qt5.qtwayland];
        });
      })
    ];
  };

  home = {pkgs, ...}: {
    home.packages = with pkgs; [
      # # guifetch
      # # listen-blue
      gnome.eog
      mate.engrampa
      gnome.nautilus
      scrcpy
      gnome.simple-scan
      gnome.evince
      gnome.gnome-system-monitor
      gnome.gnome-font-viewer
      gparted
      pavucontrol
      obs-studio
      lxde.lxrandr
      syncplay
      prismlauncher
      unityhub
      icu
      glib
      # # libreoffice
      # # gimp-dev
      # # webcord-vencord
      # cinnamon.nemo
      # krita
      # libsForQt5.kdenlive
    ];
  };
}
