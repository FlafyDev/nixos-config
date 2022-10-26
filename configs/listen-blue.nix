{
  system = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      listen-blue
    ];
  };

  home = { pkgs, ... }: {
    xdg.configFile."listen_blue/config.toml".text = ''
      collections = [
        "~/Music/music_files_1",
      ]

      # background_color = 0x7600000F
      background_color = 0x2600000F
      primary_color = 0xFFF0800F

      [[playlists]]
      title = "My Cool Playlist"
      ids = [
        "ding_orch",
        "raindrop_flower_ereve",
        "night_market_piano",
      ]
    '';
  };
}
