{ssh, ...}: {
  os.networking.wireguard = {
    enable = true;
    interfaces.wg_vps = {
      ips = ["10.10.10.11/32"];
      privateKeyFile = ssh.mera.mera_wg_vps.private;
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
}
