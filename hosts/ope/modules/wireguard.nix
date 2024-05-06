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
      #   listenPort = 51821;
      #   privateKeyFile = ssh.ope.ope_wg_private.private;
      #   peers = [
      #     {
      #       publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
      #       allowedIPs = ["10.10.11.1/32"];
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
            # allowedIPs = [
            #   "0.0.0.0/1"
            #   "128.0.0.0/3"
            #   "160.0.0.0/6"
            #   "164.0.0.0/7"
            #   "166.0.0.0/8"
            #   "167.0.0.0/10"
            #   "167.64.0.0/14"
            #   "167.68.0.0/15"
            #   "167.70.0.0/16"
            #   "167.71.0.0/19"
            #   "167.71.32.0/22"
            #   "167.71.36.0/25"
            #   "167.71.36.128/26"
            #   "167.71.36.192/28"
            #   "167.71.36.208/30"
            #   "167.71.36.212/32"
            #   "167.71.36.214/31"
            #   "167.71.36.216/29"
            #   "167.71.36.224/27"
            #   "167.71.37.0/24"
            #   "167.71.38.0/23"
            #   "167.71.40.0/21"
            #   "167.71.48.0/20"
            #   "167.71.64.0/18"
            #   "167.71.128.0/17"
            #   "167.72.0.0/13"
            #   "167.80.0.0/12"
            #   "167.96.0.0/11"
            #   "167.128.0.0/9"
            #   "168.0.0.0/5"
            #   "176.0.0.0/4"
            #   "192.0.0.0/2"
            # ];
            endpoint = "${domains.personal}:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
