{secrets, utils, lib, ...}: let
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
      "50-wg_vps" = {
        matchConfig.Name = "wg_vps";
        networkConfig = {
          Address = [[''${resolveHostname "glint.wg_vps"}/24'']];
          IPv6AcceptRA = false;
          DHCP = "no";
        };
      };
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
      "50-wg_vps" = {
        netdevConfig = {
          Name = "wg_vps";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = secrets.ssh-keys.glint.glint_wg_vps.private;
        };
        wireguardPeers = [
          {
            PublicKey = secrets.ssh-keys.mane.mane_wg_vps.public.content;
            AllowedIPs = [
              ''${resolveHostname "mane.wg_vps"}/32''
              ''${resolveHostname "ope.wg_vps"}/32''
            ];
            Endpoint = "${resolveHostname domains.personal}:51820";
            PersistentKeepalive = 25;
          }
        ];
      };
      "50-wg_private" = {
        netdevConfig = {
          Name = "wg_private";
          Kind = "wireguard";
        };
        wireguardConfig = {
          PrivateKeyFile = secrets.ssh-keys.glint.glint_wg_private.private;
        };
        wireguardPeers = [
          {
            PublicKey = secrets.ssh-keys.mane.mane_wg_private.public.content;
            AllowedIPs = [''${resolveHostname "mane.wg_private"}/32''];
            Endpoint = "${resolveHostname domains.personal}:51821";
            PersistentKeepalive = 25;
          }
          {
            PublicKey = secrets.ssh-keys.ope.ope_wg_private.public.content;
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
