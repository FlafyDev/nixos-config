{
  pkgs,
  config,
  ssh,
  osConfig,
  inputs,
  ...
}: {
  imports = [./hardware];

  users.main = "flafy";
  users.host = "ope";

  os = {
    programs.ssh.extraConfig = ''
      Host mac1-guest
      Hostname 127.0.0.1
      Port 2222
      Compression yes
    '';
    boot.binfmt.emulatedSystems = ["aarch64-linux"];
    environment.systemPackages = [
      # (pkgs.callPackage ./sunshine.nix {})
      (pkgs.sunshine.overrideAttrs (old: {
        # src = pkgs.fetchFromGitHub {
        #   owner = "LizardByte";
        #   repo = "Sunshine";
        #   rev = "60c95d638542eb97d8518857acb176ce5540c595";
        #   sha256 = "sha256-HnJMy/ghDfX5Uu6eZkX9CXulF8qviY5aBAme0O9auKc=";
        #   fetchSubmodules = true;
        # };
        # preConfigure = "echo HEYYYY; echo $CMAKE_SOURCE_DIR; ${pkgs.tree}/bin/tree ./third-party;";
        patches =
          (old.patches or [])
          ++ [
            # ./sunshine.patch
          ];

        # buildInputs = old.buildInputs ++ [pkgs.miniupnpc];
      }))
    ];
    nixpkgs.config.allowUnfree = true;
    services.zerotierone = {
      enable = true;
      joinNetworks = [
        "632ea2908508c254"
      ];
    };
    services.prometheus = {
      enable = true;
      port = 4000;
      exporters.node = {
        enable = true;
        port = 9100;
        listenAddress = "10.10.10.10";
      };
      # exporters.ping = {
      #   enable = false;
      #   listenAddress = "10.10.10.10";
      #   settings = {
      #     targets = [
      #       "8.8.8.8"
      #     ];
      #     dns = {
      #       refresh = "2m15s";
      #       nameserver = "1.1.1.1";
      #     };
      #     ping = {
      #       interval = "10s";
      #       timeout = "3s";
      #       history-size = 42;
      #       size = 120;
      #     };
      #   };
      # };

      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };

      scrapeConfigs = [
        # {
        #   job_name = "homeserver";
        #   static_configs = [
        #     {
        #       targets = ["localhost:9427"];
        #     }
        #   ];
        # }
      ];
    };
    networking = {
      firewall = {
        enable = true;
        allowedUDPPorts = [51820 53317];
        allowedTCPPorts = [53317 48010 47990 47989 47984 9100 3004 40004 40002 40003 80 443];
        allowedUDPPortRanges = [
          {
            from = 47998;
            to = 48000;
          }
        ];
      };
      wireguard = {
        enable = true;
        interfaces.wg_vps = {
          ips = ["10.10.10.10/32"];
          privateKeyFile = ssh.ope.ope_wg_vps.private;
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
  };


  # os.services = {
  #   xserver = {
  #     enable = true;
  #     dpi = 96;
  #     videoDrivers = ["amdgpu"];
  #     autorun = false;
  #   };
  # };
  # os.services.xserver.desktopManager.plasma5.enable = true;
  # os.programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

  os.services.nginx = {
    enable = true;
    virtualHosts."emoji.flafy.me" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 3004;
          ssl = false;
        }
      ];
      locations."/api" = {
        proxyPass = "http://localhost:40003";
      };
      locations."/" = {
        proxyPass = "http://localhost:40002";
      };
    };
  };

  os.services.openvscode-server = {
    enable = true;
    user = config.users.main;
    withoutConnectionToken = false;
    # package = pkgs.openvscode-server.overrideAttrs (old: {
    #   patches =
    #     (old.patches or [])
    #     ++ [
    #       ../mera/temppatch.patch
    #     ];
    # });
    # host = "0.0.0.0";
    # port = 58846;
  };
  os.nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];

  os.security = {
    rtkit.enable = true;
    pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile"; # max FD count
        value = "unlimited";
      }
    ];
  };

  os.networking.nftables = {
    enable = false;
    tables = {
      limit_bandwidth = {
        name = "limit_bandwidth";
        family = "inet";
        enable = true;

        content = ''
          chain input {
            type filter hook input priority filter; policy accept;
            # iifname enp14s0 limit rate over 3500 kbytes/second drop
          }

          chain output {
            type filter hook output priority filter; policy accept;
            # oifname enp14s0 limit rate over 3500 kbytes/second drop
          }
        '';
      };
    };
  };

  android.enable = true;
  display.greetd.enable = true;
  display.hyprland = {
    enable = true;
    headlessXorg.enable = true;
  };
  fonts.enable = true;
  printers.enable = true;

  bitwarden.enable = true;

  assets.enable = true;

  secrets.enable = true;

  themes.themeName = "amoled";

  localhosts.enable = true;
  vm.enable = true;
  games.enable = true;
  gtk.enable = true;

  # TEMP
  # os.nixpkgs.overlays = [
  #   (final: prev: {
  #     makeDBusConf = {
  #       suidHelper,
  #       serviceDirectories,
  #       apparmor ? "disabled",
  #     }:
  #       prev.makeDBusConf {
  #         serviceDirectories = serviceDirectories ++ ["/home/flafy/.testshare"];
  #         inherit suidHelper apparmor;
  #       };
  #   })
  # ];

  programs = {
    anyrun.enable = true;
    firefox.enable = true;
    gnome.enable = false;
    mpv.enable = true;
    vscode.enable = true;
    neovim.enable = true;
    cli-utils.enable = true;
    transmission.enable = true;
    direnv.enable = true;
    fish.enable = true;
    foot.enable = true;
    alacritty.enable = true;
    git.enable = true;
    nix.enable = true;
    ssh = {
      enable = true;

      matchBlocks = {
        mera = {
          identitiesOnly = true;
          identityFile = [ssh.ope.ope_to_mera.private];
        };
        "github.com" = {
          identitiesOnly = true;
          identityFile = [ssh.ope.ope_flafydev_github.private];
        };
      };

      server = {
        enable = true;
        users.${config.users.main}.keyFiles = [
          ssh.mera.mera_to_ope.public
        ];
      };
    };
    discord.enable = true;
    gui-utils.enable = true;
  };
}
