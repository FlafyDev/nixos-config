{
  home = { pkgs, ... }: {
    home.packages = [ pkgs.tofi ];
    xdg.configFile."tofi/config".text = ''
      anchor = bottom-left
      width = 30%
      height = 30
      horizontal = true
      font-size = 11
      prompt-text = "run: "
      selection-color = #4c93e6
      font = monospace
      outline-width = 0
      border-width = 0
      background-color = #000000
      min-input-width = 120
      result-spacing = 15
      padding-top = 0
      padding-bottom = 0
      padding-left = 5px
      padding-right = 5px
      margin-left = 37px
      corner-radius=10px
    '';
  };
}
