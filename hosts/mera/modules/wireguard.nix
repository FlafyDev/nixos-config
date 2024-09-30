{
  ssh,
  utils,
  ...
}: let
  inherit (utils) domains resolveHostname;
in {
  # networking.allowedPorts.udp."51821" = [domains.personal "0.0.0.0"];

  os.networking.wireguard = {
    enable = true;
    interfaces = {
      # wg_private = {
      #   ips = ["10.10.11.11/24"];
      #   privateKeyFile = ssh.mera.mera_wg_private.private;
      #   listenPort = 51821;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_private.public;
      #       allowedIPs = ["10.10.11.1/32"];
      #       endpoint = "${domains.personal}:51821";
      #     }
      #     {
      #       publicKey = builtins.readFile ssh.ope.ope_wg_private.public;
      #       allowedIPs = ["10.10.11.10/32"];
      #     }
      #   ];
      # };
      wg_vps = {
        ips = ["10.10.10.11/32"];
        privateKeyFile = ssh.mera.mera_wg_vps.private;
        peers = [
          {
            publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "${resolveHostname domains.personal}:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
