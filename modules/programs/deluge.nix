{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.deluge;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.deluge = {
    enable = mkEnableOption "deluge";
  };

  config = mkIf cfg.enable {
    os.services.deluge = {
      enable = true;
      web.enable = false;
      declarative = true;
      config = {
        download_location = "/mnt/general/downloads";
        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [6881 6889];
      };
      authFile = pkgs.writeText "deluge-auth" ''
        admin:admin:10
      '';
    };
  };
}
