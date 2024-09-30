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
      # wg_private = {
      #   ips = ["10.10.11.10/24"];
      #   privateKeyFile = ssh.ope.ope_wg_private.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_private.public;
      #       allowedIPs = ["10.10.11.1/32"];
      #       endpoint = "${domains.personal}:51821";
      #     }
      #     {
      #       publicKey = builtins.readFile ssh.mera.mera_wg_private.public;
      #       allowedIPs = ["10.10.11.11/32"];
      #       endpoint = "${resolveHostname "mera.lan1"}:51821";
      #     }
      #     # {
      #     #   publicKey = builtins.readFile ssh.mera.bara_wg_vps.public;
      #     #   allowedIPs = ["10.10.11.12/32"];
      #     # }
      #     # {
      #     #   publicKey = builtins.readFile ssh.mera.noro_wg_vps.public;
      #     #   allowedIPs = ["10.10.11.13/32"];
      #     # }
      #   ];
      # };
      wg_vps = let
        ip = "${pkgs.iproute2}/bin/ip";
      in {
        ips = ["10.10.10.10/32"];
        privateKeyFile = ssh.ope.ope_wg_vps.private;
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
