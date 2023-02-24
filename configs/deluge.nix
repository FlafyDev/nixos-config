{
  system = {pkgs, ...}: {
    services.deluge = {
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

    # environment.systemPackages = with pkgs; [
    #   transmission
    #   transmission-qt
    # ];
  };
}
