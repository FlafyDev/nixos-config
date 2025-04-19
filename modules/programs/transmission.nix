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
      # transmission-remote-gtk
    ];

    os.services.transmission = {
      enable = true;
      package = pkgs.transmission_4;
      settings = {
        rpc-whitelist-enabled = false;
        rpc-bind-address = "0.0.0.0";
        download-dir = "/share/torrents/transmission/downloaded/";
        watch-dir = "/share/torrents/transmission/watch/";
        watch-dir-enabled = true;
        incomplete-dir-enabled = false;
        script-torrent-done-enabled = true;
        downloadDirPermissions = "770";
        speed-limit-down-enabled = false;
        speed-limit-up = 300;
        speed-limit-up-enabled = true;
        alt-speed-down = 3500;
        alt-speed-up = 300;
      };
    };
  };
}
