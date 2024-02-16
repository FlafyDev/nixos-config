{
  ssh,
  utils,
  ...
}: let
  inherit (utils) domains;
in {
  networking.vpsForwarding.mane.udp = ["51821"];

  os.networking.wireguard = {
    enable = true;
    interfaces = {
      # wg_private = {
      #   listenPort = 51821;
      #   ips = ["10.10.11.10/32"];
      #   privateKeyFile = ssh.ope.ope_wg_private.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.bara.bara_wg_private.public;
      #       allowedIPs = ["10.10.11.12/32"];
      #       persistentKeepalive = 25;
      #     }
      #   ];
      # };
      wg_vpn = {
        ips = ["10.10.12.10/32"];
        privateKeyFile = ssh.ope.ope_wg_vps.private;
        peers = [
          {
            publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
            # allowedIPs = ["0.0.0.0/0" "::/0"];
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "${domains.personal}:51822";
            persistentKeepalive = 25;
          }
        ];
      };
      # wg_vps = {
      #   ips = ["10.10.10.10/32"];
      #   privateKeyFile = ssh.ope.ope_wg_vps.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
      #       # allowedIPs = ["10.10.10.1/32" "0.0.0.0/0"];
      #       # allowedIPs = [ "0.0.0.0/5" "8.0.0.0/7" "10.0.0.0/13" "10.8.0.0/15" "10.10.0.0/21" "10.10.8.0/23" "10.10.10.0/29" "10.10.10.1/32" "10.10.10.8/31" "10.10.10.11/32" "10.10.10.12/30" "10.10.10.16/28" "10.10.10.32/27" "10.10.10.64/26" "10.10.10.128/25" "10.10.11.0/24" "10.10.12.0/22" "10.10.16.0/20" "10.10.32.0/19" "10.10.64.0/18" "10.10.128.0/17" "10.11.0.0/16" "10.12.0.0/14" "10.16.0.0/12" "10.32.0.0/11" "10.64.0.0/10" "10.128.0.0/9" "11.0.0.0/8" "12.0.0.0/6" "16.0.0.0/4" "32.0.0.0/3" "64.0.0.0/2" "128.0.0.0/1" ];
      #       allowedIPs = ["10.10.10.1/32"];
      #       endpoint = "${domains.personal}:51820";
      #       persistentKeepalive = 25;
      #     }
      #   ];
      # };
    };
  };
}
