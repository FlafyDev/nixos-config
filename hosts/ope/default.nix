{
  lib,
  root,
  configs,
  ...
}: {
  imports = [./hardware]; # ++ ((import (root + "/utils") {inherit lib;}).getModules (toString ./modules));

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
    services.prometheus = {
      enable = true;
      port = 4000;
      exporters.node = {
        enable = true;
        port = 9100;
        listenAddress = "ope.wg_private.flafy.me";
      };

      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
    };
    networking = {
      firewall = {
        enable = true;
        #   allowedUDPPorts = [51820 53317 51821];
        #   allowedTCPPorts = [53317 48010 47990 47989 47984 9100 3004 40004 40002 40003 80 443 58846 48002];
        #   allowedUDPPortRanges = [
        #     {
        #       from = 47998;
        #       to = 48000;
        #     }
        #   ];
      };
    };
  };

  networking.enable = true;

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

  # os.networking.nftables = {
  #   enable = true;
  #   tables = {
  #     limit_bandwidth = {
  #       name = "limit_bandwidth";
  #       family = "inet";
  #       enable = false;
  #
  #       content = ''
  #         chain input {
  #           type filter hook input priority filter; policy accept;
  #           # iifname enp14s0 limit rate over 3500 kbytes/second drop
  #         }
  #
  #         chain output {
  #           type filter hook output priority filter; policy accept;
  #           # oifname enp14s0 limit rate over 3500 kbytes/second drop
  #         }
  #       '';
  #     };
  #     allow_ports = {
  #       name = "allow_ports";
  #       family = "inet";
  #       enable = false;
  #       content = ''
  #         chain input {
  #           type filter hook input priority 0;
  #
  #           iif lo accept
  #
  #           ct state established,related accept
  #
  #           tcp dport {9100,58846} accept
  #
  #           drop
  #         }
  #       '';
  #     };
  #   };
  # };

  android.enable = true;
  display.greetd.enable = true;
  display.greetd.command = "offload-igpu Hyprland";
  display.hyprland = {
    enable = true;
    sunshine.enable = true;
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

  secrets.enable = true;

  themes.themeName = "amoled";

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
    nix = {
      enable = true;
      patch = true;
    };
    discord.enable = true;
    gui-utils.enable = true;
  };
}
