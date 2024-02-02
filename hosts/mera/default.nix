{
  pkgs,
  config,
  osConfig,
  resolveHostname,
  ssh,
  ...
}: {
  imports = [./hardware];

  users.main = "server";
  users.host = "mera";

  secrets.enable = true;
  printers.enable = true;

  networking.enable = true;
  networking.vpsForwarding.mane.tcp = ["80" "443"];
  networking.allowedPorts.tcp."22" = ["mera.lan1.flafy.me"];

  os.services.nginx = let
    sslConfig = {
      sslCertificate = osConfig.age.secrets.flafy_me-cert.path;
      sslCertificateKey = osConfig.age.secrets.flafy_me-key.path;
      addSSL = true;
    };
    domain = "flafy.me";
  in {
    enable = true;
    defaultListen = [
      {
        addr = resolveHostname "mera.wg_vps.flafy.me";
        ssl = true;
        port = 443;
      }
      {
        addr = resolveHostname "mera.wg_vps.flafy.me";
        ssl = false;
        port = 80;
      }
    ];
    virtualHosts = {
      ${domain} =
        sslConfig
        // {
          serverAliases = [domain "www.${domain}"];
          locations."/" = {
            proxyPass = "http://localhost:40004";
          };
        };
      "emoji.${domain}" =
        sslConfig
        // {
          locations."/" = {
            proxyPass = "http://localhost:40002";
          };
          locations."/api" = {
            proxyPass = "http://localhost:40003";
          };
        };
    };
  };
  services = {
    games = {
      badTimeSimulator = {
        enable = true;
        port = 40004;
      };
      minecraft.enable = false;
    };
    emojiDrawing = {
      enable = true;
      webPort = 40002;
      serverPort = 40003;
      dataDir = "/mnt/general/var/lib/emoji-drawing";
    };
  };
  # os.networking.hostName = config.users.host;

  # bitwarden.enable = true;

  # os.services.nginx = {
  #   enable = true;
  #   virtualHosts."emoji.flafy.me" = {
  #     listen = [
  #       {
  #         addr = "10.10.10.10";
  #         port = 80;
  #         ssl = false;
  #       }
  #     ];
  #     locations."/api" = {
  #       proxyPass = "http://localhost:40003";
  #     };
  #     locations."/" = {
  #       proxyPass = "http://localhost:40002";
  #     };
  #   };
  # };
  # services.emojiDrawing = {
  #   enable = true;
  #   webPort = 40002;
  #   serverPort = 40003;
  #   dataDir = "/mnt/general/var/lib/emoji-drawing";
  # };
  os.networking = {
    firewall = {
      enable = true;
      # allowedTCPPorts = [58846 8001 25565 80 21 22 3001 40004 40002 40003 443];
      # allowedUDPPorts = [51820 58846 25565 80 21 22];
    };
    wireguard = {
      enable = true;
      interfaces.wg_vps = {
        ips = ["10.10.10.11/32"];
        privateKeyFile = ssh.mera.mera_wg_vps.private;
        peers = [
          {
            publicKey = builtins.readFile ssh.mane.mane_wg_vps.public;
            allowedIPs = ["10.10.10.1/32"];
            endpoint = "flafy.me:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
  # services.games.badTimeSimulator.enable = true;
  programs = {
    # programs.transmission.enable = true;
    git.enable = true;
    nix.enable = true;
    fish.enable = true;
    ssh = {
      enable = true;
      sftp.enable = true;

      matchBlocks = {
        ope = {
          identitiesOnly = true;
          identityFile = [ssh.mera.mera_to_ope.private];
        };
      };

      server = {
        enable = true;

        users.${config.users.main}.keyFiles = [
          ssh.ope.ope_to_mera.public
        ];
        users.root.keyFiles = [
          ssh.ope.ope_to_mera.public
        ];
      };
    };
  };
}
