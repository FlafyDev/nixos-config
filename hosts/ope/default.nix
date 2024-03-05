{
  lib,
  utils,
  pkgs,
  ...
}: let
  inherit (utils) getHostname domains;
in {
  imports = [./hardware];

  users.main = "flafy";
  users.host = "ope";

  containers.testcon = {
    autoStart = true;
    # privateNetwork = true;
    extraFlags = ["--network-namespace-path=/run/netns/vpn"];
    hostAddress = "10.10.15.10";
    localAddress = "10.10.15.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

    # vpnForwards = {
    #   enable = true;
    #   mane = {
    #     tcp.ports = ["27->2200"];
    #     udp.ports = ["27->2200"];
    #   };
    # };

    bindMounts = {
      "/etc/resolv.conf" = {
        hostPath = toString (pkgs.writeText "resolv.conf" ''
          nameserver 9.9.9.9
          nameserver 1.1.1.1
        '');
        isReadOnly = true;
      };
    };

    forwardPorts = [
      {
        protocol = "tcp";
        hostPort = 5000;
        containerPort = 5000;
      }
    ];

    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services = {
        games = {
          badTimeSimulator = {
            enable = true;
            hostname = "0.0.0.0";
            port = 5000;
          };
        };
      };

      networking = {
        enable = true;
        allowedPorts = [1000];
      };

      system.stateVersion = "23.11";
      networking.useHostResolvConf = lib.mkForce false;
    };
  };

  os = {
    boot.binfmt.emulatedSystems = ["aarch64-linux"];
    services.prometheus = {
      enable = true;
      port = 4000;
      exporters.node = {
        enable = true;
        port = 9100;
        listenAddress = getHostname "ope.wg_private";
      };

      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
    };
  };

  os.services.nginx = {
    enable = true;
    virtualHosts."emoji.${domains.personal}" = {
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
    enable = true;
    tables = {
      limit_bandwidth = {
        name = "limit_bandwidth";
        family = "inet";
        enable = true;

        content = ''
          chain input {
            type filter hook input priority filter; policy accept;
            iifname enp14s0 limit rate over 2800 kbytes/second drop
          }

          chain output {
            type filter hook output priority filter; policy accept;
            oifname enp14s0 limit rate over 2800 kbytes/second drop
          }
        '';
      };
    };
  };

  android.enable = true;
  display.greetd.enable = true;
  display.greetd.command = "offload-igpu Hyprland";

  # TCP: 47984, 47989, 48010
  # UDP: 47998-48000, 48002, 48010

  networking.allowedPorts.tcp."47984,47989,48010" = [(getHostname "ope.wg_private")];
  networking.allowedPorts.udp."47998-48000" = [(getHostname "ope.wg_private")];
  networking.allowedPorts.udp."48002,48010" = [(getHostname "ope.wg_private")];

  display.hyprland = {
    enable = true;
    headlessXorg.enable = true;
    monitors = [
      "eDP-1,disable"
      "HDMI-A-1,1920x1080@60,0x0,1"
      "HDMI-A-1,addreserved,0,40,0,0"
      "HDMI-A-2,1920x1080@60,0x0,1"
      "HDMI-A-2,addreserved,0,40,0,0"
    ];
  };
  fonts.enable = true;
  printers.enable = true;

  bitwarden.enable = true;

  assets.enable = true;

  networking.enable = true;

  secrets.enable = true;

  themes.themeName = "amoled";

  vm.enable = true;
  games.enable = true;
  gtk.enable = true;

  # networking.exposeLocalhost.tcp = ["9091"];
  # networking.allowedPorts.tcp."9091" = [(getHostname "ope.wg_private")];

  # os.networking.nftables = {
  #   tables = {
  #     allow_ports = {
  #       name = "allow_ports";
  #       family = "inet";
  #       enable = true;
  #       content = ''
  #         chain input {
  #           type filter hook input priority 0;
  #
  #           iif lo accept
  #
  #           ct state established,related accept
  #
  #           ip6 nexthdr icmpv6 accept
  #           ip protocol icmp accept
  #
  #           tcp dport 9091 accept
  #
  #           icmp type echo-request  accept comment "allow ping"
  #
  #           icmpv6 type != { nd-redirect, 139 } accept comment "Accept all ICMPv6 messages except redirects and node information queries (type 139).  See RFC 4890, section 4.4."
  #           ip6 daddr fe80::/64 udp dport 546 accept comment "DHCPv6 client"
  #
  #           drop
  #         }
  #       '';
  #     };
  #   };
  # };

  # networking.allowedPorts.tcp."8096" = ["*"];
  os.services.jellyfin = {
    enable = true;
  };
  # os.systemd.services.jellyfin.serviceConfig.Group = lib.mkForce "jellyfin,transmission";
  os.users.users.jellyfin = {
    extraGroups = [
      "transmission"
    ];
  };

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
    nix = {
      enable = true;
      patch = true;
    };
    discord.enable = true;
    gui-utils.enable = true;
  };
}
