{ssh, ...}: {
  os.networking.wireguard = {
    enable = true;
    interfaces.wg_vps = {
      ips = ["10.10.10.1/24"];
      listenPort = 51820;
      privateKeyFile = ssh.mane.mane_wg_vps.private;
      peers = [
        {
          publicKey = builtins.readFile ssh.ope.ope_wg_vps.public;
          allowedIPs = ["10.10.10.10/32"];
        }
        {
          publicKey = builtins.readFile ssh.mera.mera_wg_vps.public;
          allowedIPs = ["10.10.10.11/32"];
        }
      ];
    };
  };

  networking.allowedPorts.udp."51820" = ["flafy.me"];
}
