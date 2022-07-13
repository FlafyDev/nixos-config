{
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.lightdm = {
      enable = true;
    };
  };

  environment.gnome.excludePackages = (with nixpkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with nixpkgs.gnome; [
    cheese # webcam tool
    gnome-music
    # gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnome.dconf-editor
  ];
}