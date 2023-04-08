mkSystem: let
  username = "flafydev";
in
  mkSystem {
    inherit username;
    args = {
      theme = {
        wallpaper = "/home/${username}/Pictures/wallpaper.png";
      };
    };
  } {
    configs = cfgs:
      with cfgs; [
        firefox
        helix
        greetd
        direnv
        git
        mpv
        nix
        printer-4500
        zsh
        starship
        ( neovim { neovide = true; } )
        gtk
        qt
        hyprland
        foot
        utility-gui
        utility-scripts
        utility-cli
        ssh
        qutebrowser
        chromium
        fonts
        bspwm
        alacritty
        picom
        mouse-g502-xserver
        wine
        deluge
        remote-control
        cuda
      ];

    system = _: {
      time.timeZone = "Israel";
    };
  }
