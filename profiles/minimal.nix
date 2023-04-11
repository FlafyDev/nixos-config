mkSystem: let
  username = "flafydev";
in
  mkSystem {
    inherit username;
  } {
    configs = cfgs:
      with cfgs; [
        direnv
        git
        nix
        printer-4500
        zsh
        starship
        (neovim {neovide = false;})
        utility-scripts
        utility-cli
        ssh
      ];

    system = _: {
      time.timeZone = "Israel";
    };
  }
