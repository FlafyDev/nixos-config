{ssh, ...}: {
  os.networking.wireguard = {
    enable = true;
    interfaces = {
      wg_private = {
        listenPort = 51821;
        ips = ["10.10.11.10/32"];
        privateKeyFile = ssh.ope.ope_wg_private.private;
        peers = [
          {
            publicKey = builtins.readFile ssh.bara.bara_wg_private.public;
            allowedIPs = ["10.10.11.12/32"];
            # endpoint = "flafy.me:51820";
            persistentKeepalive = 25;
          }
        ];
      };
      wg_vps = {
        ips = ["10.10.10.10/32"];
        privateKeyFile = ssh.ope.ope_wg_vps.private;
        peers = [
          {
            publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
            allowedIPs = ["10.10.10.1/32"];
            endpoint = "flafy.me:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  networking.vpsForwarding.mane.udp = [ "51820" ];
  # networking.allowedPorts.tcp."51821" = [ "ope.wg_private.flafy.me" ];
}
