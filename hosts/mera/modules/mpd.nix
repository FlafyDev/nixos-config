{
  secrets,
  lib,
  ...
}: {
  # networking.allowedPorts.tcp = {
  #   "6600" = ["*"];
  #   "1704" = ["*"];
  #   "1705" = ["*"];
  #   "1780" = ["*"];
  #   "5030" = ["*"];
  #   "50300" = ["*"];
  # };
  # networking.vpnNamespace.vpn.ports.tcp = ["50300"];
  # networking.forwardPorts = {
  #   "10.10.15.11" = {
  #     tcp = ["5030"];
  #     # fromInterface = "enp4s0";
  #     masquerade = true;
  #   };
  # };
  #
  # os.environment.persistence = {
  #   "/persist2" = {
  #     hideMounts = true;
  #     directories = [
  #       {
  #         directory = "/var/lib/mpd";
  #         user = "root";
  #         group = "root";
  #       }
  #       {
  #         directory = "/var/lib/mpdscribble";
  #         user = "root";
  #         group = "root";
  #       }
  #     ];
  #   };
  # };
  # os.services.snapserver = {
  #   enable = true;
  #   buffer = 400;
  #   streams.default = {
  #     type = "pipe";
  #     location = "/run/snapserver/snapfifo";
  #     query = {
  #       sampleformat = "48000:16:2";
  #       codec = "flac";
  #       mode = "create";
  #     };
  #   };
  # };
  #
  # services.slskd = {
  #   enable = true;
  #   group = "mpd";
  #   domain = null;
  #   environmentFile = secrets.slskd;
  #   settings = {
  #     shares.directories = [
  #       "/var/lib/mpd/music"
  #     ];
  #     directories.downloads = "/var/lib/mpd/music";
  #   };
  # };
  # os.systemd.services.slskd.serviceConfig.ReadOnlyPaths = lib.mkForce [];
  # os.systemd.services.slskd.serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  #
  # os.services.mpdscribble = {
  #   enable = true;
  #   journalInterval = 60;
  #   endpoints = {
  #     "last.fm" = {
  #       username = "flafydev";
  #       passwordFile = secrets.lastfm-flafydev;
  #     };
  #   };
  # };
  # os.systemd.services.mpdscribble.serviceConfig = {
  #   DynamicUser = lib.mkForce false;
  #   User = "mpdscribble";
  # };
  # os.users.users = {
  #   mpdscribble = {
  #     group = "mpdscribble";
  #     home = "/var/lib/mpdscribble";
  #     isNormalUser = true;
  #   };
  # };
  # os.users.groups.mpdscribble = {};
  #
  # os.services.mpd = {
  #   enable = true;
  #   network = {
  #     listenAddress = "any";
  #     port = 6600;
  #   };
  #   extraConfig = ''
  #     audio_output {
  #         type            "fifo"
  #         name            "mypipe"
  #         path            "/run/snapserver/snapfifo"
  #         format          "48000:16:2"
  #         mixer_type      "software"
  #     }
  #   '';
  # };
}
