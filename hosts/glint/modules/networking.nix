{ssh, utils, lib, ...}: let
  inherit (utils) domains resolveHostname;
in {
  networking.enable = true;

  os.networking.networkmanager.enable = lib.mkForce true;
  os.networking.networkmanager.unmanaged = [
    "except-interface-name:wl*"
  ];
  os.systemd.services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
  os.systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks = {
      "50-wired" = {
        enable = true;
        matchConfig.Name = "en*";
        networkConfig = {
          DHCP = "yes";
        };
      };
      # "50-wireless" = {
      #   enable = true;
      #   matchConfig.Name = "wl*";
      #   networkConfig = {
      #     DHCP = "yes";
      #   };
      # };
      "50-wg_private" = {
        matchConfig.Name = "wg_private";
        networkConfig = {
          Address = [[''${resolveHostname "glint.wg_private"}/24'']];
          IPv6AcceptRA = false;
          DHCP = "no";
        };
      };
    };
    netdevs = {
      "50-wg_private" = {
        netdevConfig = {
          Name = "wg_private";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = ssh.glint.glint_wg_private.private;
        };
        wireguardPeers = [
          {
            PublicKey = builtins.readFile ssh.mane.mane_wg_private.public;
            AllowedIPs = [''${resolveHostname "mane.wg_private"}/32''];
            Endpoint = "${resolveHostname domains.personal}:51821";
            PersistentKeepalive = 25;
          }
          {
            PublicKey = builtins.readFile ssh.ope.ope_wg_private.public;
            AllowedIPs = [''${resolveHostname "ope.wg_private"}/32''];
            Endpoint = "${resolveHostname domains.personal}:51822";
            PersistentKeepalive = 25;
          }
        ];
      };
    };
  };

  os.networking.nftables.tables.filter = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority 0; policy accept;
        meta nftrace set 1
        tcp dport 22 meta mark set 88  # SSH
        iifname wg_private meta mark set 88
      }
    '';
  };
}
