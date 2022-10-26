{
  system = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      guifetch
    ];
  };

  home = { pkgs, ... }: {
    xdg.configFile."guifetch/guifetch.toml".text = ''
      background_color = 0x2600000F
      os_image = "${../assets/nixween.png}"
    '';
  };
}
