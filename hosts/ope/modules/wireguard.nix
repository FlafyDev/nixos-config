{
  ssh,
  utils,
  lib,
  pkgs,
  ...
}: let
  inherit (utils) domains resolveHostname;
in {
  os.networking.wireguard = {
    enable = true;
    interfaces = {
      wg_vps = let
        ip = "${pkgs.iproute2}/bin/ip";
      in {
        ips = ["10.10.10.10/32"];
        privateKeyFile = ssh.ope.ope_wg_vps.private;

        peers = [
          {
            publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "${domains.personal}:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
