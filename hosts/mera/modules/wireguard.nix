{
  ssh,
  utils,
  ...
}: let
  inherit (utils) domains;
in {
  os.networking.wireguard = {
    enable = true;
    interfaces.wg_vps = {
      ips = ["10.10.10.11/32"];
      privateKeyFile = ssh.mera.mera_wg_vps.private;
      peers = [
        {
          publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
          # allowedIPs = ["0.0.0.0/0"];
          allowedIPs = ["10.10.10.1/32"];
          endpoint = "${domains.personal}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
