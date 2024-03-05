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
        interfaceNamespace = "vpn";
        socketNamespace = "init";
        preSetup = ''
          ${ip} netns add vpn || true

          ${ip} link add name vethhost0 type veth peer name vethvpn0 || true
          ${ip} link set vethvpn0 netns vpn || true
          ${ip} addr add 10.10.15.10/24 dev vethhost0 || true
          ${ip} netns exec vpn ip addr add 10.10.15.11/24 dev vethvpn0 || true
          ${ip} link set vethhost0 up || true
          ${ip} netns exec vpn ip link set vethvpn0 up || true
        '';

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
