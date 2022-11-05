{
  inputs = {
    listen-blue = {
      url = "github:flafydev/listen_blue";
      # url = "path:/mnt/general/repos/flafydev/music_player";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {listen-blue, ...}: {
    overlays = _: [listen-blue.overlays.default];
  };

  system = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      listen-blue
    ];
  };

  home = { pkgs, theme, ... }: let
    primaryColor = if theme == "Halloween" then "0xFFF0800F" else "0xFF52afea";
  in {
    xdg.configFile."listen_blue/config.toml".text = ''
      collections = [
        "~/Music/music_files_1",
      ]

      # background_color = 0x7600000F
      background_color = 0x2600000F
      primary_color = ${primaryColor}

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
