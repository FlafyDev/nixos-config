mkSystem: let
  username = "flafydev";
in
  mkSystem {
    inherit username;
    args = {
      theme = {
        wallpaper = "/home/${username}/Pictures/wallpaper.png";
        colors = {
          activeBorder = "29A4BD";
          base16 = {
            base00 = "182430";
            base01 = "243C54";
            base02 = "46290A";
            base03 = "616D78";
            base04 = "74AFE7";
            base05 = "C8E1F8";
            base06 = "DDEAF6";
            base07 = "8F98A0";
            base08 = "4CE587";
            base09 = "F6A85C";
            base0A = "82AAFF";
            base0B = "C3E88D";
            base0C = "5FD1FF";
            base0D = "82AAFF";
            base0E = "FF84DD";
            base0F = "BBD2E8";
          };
        };
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
        # zsh
        fish
        # starship
        (neovim {neovide = false;})
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
        waybar
        steam
      ];

    system = _: {
      time.timeZone = "Israel";
    };
  }
