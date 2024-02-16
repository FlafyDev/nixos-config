{
  ssh,
  utils,
  ...
}: let
  inherit (utils) domains;
in {
  networking.allowedPorts.tcp."80" = ["*"];
  os.networking.wireguard = {
    enable = true;
    interfaces.wg_vpn = {
      ips = ["10.10.12.1/24"];
      listenPort = 51822;
      privateKeyFile = ssh.mane.mane_wg_vps.private;
      peers = [
        {
          publicKey = builtins.readFile ssh.ope.ope_wg_vps.public;
          allowedIPs = ["10.10.12.10/32"];
          # allowedIPs = ["0.0.0.0/0" "::/0"];
        }
      ];
    };
    interfaces.wg_vps = {
      ips = ["10.10.10.1/24"];
      listenPort = 51820;
      privateKeyFile = ssh.mane.mane_wg_vps.private;
      peers = [
        {
          publicKey = builtins.readFile ssh.ope.ope_wg_vps.public;
          allowedIPs = ["10.10.10.10/32"];
          # allowedIPs = ["0.0.0.0/0" "::/0"];
        }
        {
          publicKey = builtins.readFile ssh.mera.mera_wg_vps.public;
          allowedIPs = ["10.10.10.11/32"];
        }
      ];
    };
  };

  networking.allowedPorts.udp."51820,51822" = [domains.personal];
}
