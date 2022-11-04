{
  home = { pkgs, ... }: {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.alacritty}/bin/alacritty";
      theme = "${pkgs.rofiThemes.sideNavy}/config.rasi";
    };
  };
}
