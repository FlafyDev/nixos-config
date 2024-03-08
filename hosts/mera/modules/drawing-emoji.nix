_: {
  os.environment.persistence = {
    "/persist2" = {
      hideMounts = true;
      directories = [
        {
          directory = "/var/lib/emoji-drawing";
          user = "root";
          group = "root";
        }
      ];
    };
  };

  containers.maneVpn2 = {
    bindMounts."/var/lib/emoji-drawing".isReadOnly = false;
    config.services.emojiDrawing = {
      enable = true;
      webPort = 40002;
      serverPort = 40003;
      dataDir = "/var/lib/emoji-drawing";
    };
  };
}
