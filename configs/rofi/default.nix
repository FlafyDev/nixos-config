{
  inputs = {
    rofi-themes = {
      url = "github:adi1090x/rofi";
      flake = false;
    };
  };

  add = {rofi-themes, ...}: {
    overlays = _: [
      (_final: prev: {
        rofiThemes = {
          sideNavy =
            prev.callPackage
            ./mk-rofi-theme.nix {
              src = rofi-themes;
              theme = {
                type = 3;
                style = 9;
                colorScheme = "navy";
              };
            };
        };
      })
    ];
  };

  home = {pkgs, ...}: {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.alacritty}/bin/alacritty";
      theme = "${pkgs.rofiThemes.sideNavy}/config.rasi";
    };
  };
}
