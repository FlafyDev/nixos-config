{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.transmission;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.transmission = {
    enable = mkEnableOption "transmission";
  };

  config = mkIf cfg.enable {
    users.groups = ["transmission"];

    os.environment.systemPackages = with pkgs; [
      transmission-remote-gtk
    ];

    os.services.transmission = {
      enable = true;
      settings = {
        download-dir = "/share/torrents/transmission/downloaded/";
        watch-dir = "/share/torrents/transmission/watch/";
        watch-dir-enabled = true;
        incomplete-dir-enabled = false;
        script-torrent-done-enabled = true;
        downloadDirPermissions = "770";
      };
    };
  };
}
