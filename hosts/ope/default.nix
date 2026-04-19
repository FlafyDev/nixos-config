{
  lib,
  utils,
  pkgs,
  upkgs,
  inputs,
  secrets,
  config,
  ...
}: let
  inherit (utils) getHostname domains resolveHostname;
in {
  imports = [
    ./hardware
    # flatpak
    {
      os.services.flatpak.enable = true;
      hm.home.packages = with pkgs; [
        flatpak
        gnome-software
      ];
    }
    # {
    #   os = {
    #     services.desktopManager.plasma6.enable = true;
    #     environment.systemPackages = [
    #       inputs.kwin-effects-forceblur.packages.${pkgs.system}.default
    #     ];
    #     environment.plasma6.excludePackages = with pkgs.kdePackages; [
    #       plasma-browser-integration
    #       konsole
    #       oxygen
    #     ];
    #   };
    # }
  ];
  os.virtualisation.vmware.host.enable = true;

  os.services.davfs2.enable = true;
  os.services.autofs = {
    enable = true;
    autoMaster = let
      davfsConfig = pkgs.writeText "davfs-config" ''
        secrets ${secrets.nextcloud.ope.davfs}
      '';
      mapConf = pkgs.writeText "auto" ''
        nextcloud -fstype=davfs,conf=${davfsConfig},file_mode=600,dir_mode=700,uid=1000,rw :http\://10.0.0.41:5000/remote.php/webdav/
      '';
    in ''
      /mnt/nextcloud file:${mapConf}
    '';
  };

  os.environment.systemPackages = [
    pkgs.rocmPackages.rocm-smi
    pkgs.rocmPackages.rocminfo

    pkgs.waypipe
    pkgs.icu
    (
      (pkgs.flutter341.override ({ flutter, ... }: {
          flutter = flutter.override {
          flutterTools = flutter.tools.overrideAttrs ({ postPatch ? "", ... }: {
              postPatch = postPatch + ''
              substituteInPlace lib/src/features.dart \
                  --replace-quiet 'const windowingFeature = Feature(' 'const windowingFeature = Feature.fullyEnabled(' \
                  --replace-quiet 'master: FeatureChannelSetting(available: true),' ""
              '';
          });
          };
      }))
    )
  ];
  # services.waypipe.server.enable = true;

  users.main = "flafy";
  users.host = "ope";

  # containers.showcaseBot = {
  #   autoStart = true;
  #
  #   bindMounts = {
  #     "/home/flafy/Games" = {
  #       isReadOnly = false;
  #     };
  #     "/home/flafy/repos/flafydev/showcase-bot" = {
  #       isReadOnly = false;
  #     };
  #     "/dev/dri" = {
  #       isReadOnly = false;
  #     };
  #     "/run/opengl-driver" = {
  #       isReadOnly = true;
  #     };
  #   };
  #
  #   allowedDevices = [
  #     {
  #       modifier = "rw";
  #       node = "/dev/dri/renderD128";
  #     }
  #     {
  #       modifier = "rw";
  #       node = "/dev/dri/renderD129";
  #     }
  #     {
  #       modifier = "rw";
  #       node = "/dev/dri/card0";
  #     }
  #     {
  #       modifier = "rw";
  #       node = "/dev/dri/card1";
  #     }
  #   ];
  #
  #   # ephemeral = false;
  #
  #   specialArgs = {
  #     inherit secrets;
  #   };
  #   # allowedDevices = [
  #   #   {
  #   #     modifier = "rw";
  #   #     node = "/dev/dri/renderD128";
  #   #   }
  #   #   {
  #   #     modifier = "rw";
  #   #     node = "/dev/dri/card0";
  #   #   }
  #   # ];
  #
  #   config = {lib, ...}: {
  #     users.main = "showcasebot";
  #     networking.enable = true;
  #     os = {
  #       system.stateVersion = "23.11";
  #       services = {
  #         pipewire = {
  #           # systemWide = true;
  #           enable = true;
  #           alsa.enable = true;
  #           alsa.support32Bit = true;
  #           pulse.enable = true;
  #         };
  #       };
  #       environment.systemPackages = with pkgs; [
  #         dart
  #         wineWowPackages.unstable
  #         cage
  #         wf-recorder
  #         wlr-randr
  #         pulseaudio
  #       ];
  #     };
  #   };
  # };

  # os.services.pipewire.wireplumber.extraLuaConfig.bluetooth."headphones-no-switch" = ''
  #   wireplumber.settings = {
  #     bluetooth.autoswitch-to-headset-profile = false
  #   }
  # '';

  # os.systemd.services = {
  #   docker.serviceConfig.NetworkNamespacePath = "/var/run/netns/vpn";
  # };
  # os.networking.nftables = {
  #   enable = true;
  #   tables = lib.mkForce {
  #     # traceall = {
  #     #   name = "traceall";
  #     #   family = "ip";
  #     #   enable = true;
  #     #
  #     #   content = ''
  #     #     chain prerouting {
  #     #         type filter hook prerouting priority -350; policy accept;
  #     #         meta nftrace set 1
  #     #     }
  #     #
  #     #     chain output {
  #     #         type filter hook output priority -350; policy accept;
  #     #         meta nftrace set 1
  #     #     }
  #     #   '';
  #     # };
  #     # nattest = {
  #     #   name = "nattest";
  #     #   family = "ip";
  #     #   enable = true;
  #     #
  #     #   content = ''
  #     #     chain postrouting {
  #     #         type nat hook postrouting priority 100; policy accept;
  #     #         oifname "enp14s0" ip saddr 10.10.15.11/24 masquerade
  #     #     }
  #     #
  #     #     chain forward {
  #     #         type filter hook forward priority 0; policy drop;
  #     #         iifname "enp14s0" oifname "vethhost0" accept
  #     #         oifname "enp14s0" iifname "vethhost0" accept
  #     #     }
  #     #   '';
  #     # };
  #     # virutalmachine = {
  #     #   name = "virutalmachine";
  #     #   family = "inet";
  #     #   enable = true;
  #     #
  #     #   content = ''
  #     #      chain postrouting {
  #     #         type nat hook postrouting priority 100; policy accept;
  #     #
  #     #         # ip saddr 192.168.122.0/24 masquerade
  #     #         oifname != "virbr0" iifname "virbr0" masquerade
  #     #      }
  #     #
  #     #      chain input {
  #     #         type filter hook forward priority 0; policy drop;
  #     #
  #     #         iifname "virbr0" accept comment "accept from virtual VM"
  #     #      }
  #     #
  #     #      chain forward {
  #     #         type filter hook forward priority 0; policy drop;
  #     #
  #     #         iifname "virbr0" accept comment "accept VM interface as input"
  #     #         oifname "virbr0" accept comment "accept VM interface as output"
  #     #      }
  #     #   '';
  #     # };
  #   };
  # };

  os = {
    services = {
      pipewire = {
        enable = true;
        wireplumber = {
          # configPackages = [
          #   (pkgs.writeTextFile {
          #     name = "wireplumber-bluez-config";
          #     text = ''
          #       monitor.bluez.rules = [
          #         {
          #           matches = [
          #             {
          #               ## This matches all bluetooth devices.
          #               device.name = "~bluez_card.*"
          #             }
          #           ]
          #           actions = {
          #             update-props = {
          #               bluez5.auto-connect = [ a2dp_sink ]
          #               bluez5.hw-volume = [ a2dp_sink ]
          #             }
          #           }
          #         }
          #       ]
          #
          #       monitor.bluez.properties = {
          #         bluez5.roles = [ a2dp_sink ]
          #         bluez5.hfphsp-backend = "none"
          #       }
          #     '';
          #     destination = "/share/wireplumber/bluetooth.lua.d/51-bluez-config.lua";
          #   })
          # ];
          # extraConfig = {
          #   "no-bluetooth-headphones-switch" = {
          #     "wireplumber.settings" = {
          #       bluetooth.autoswitch-to-headset-profile = false;
          #     };
          #   };
          # };
        };
        # extraConfig.pipewire = {
        #   "module-allow-priority" = false;
        # };
      };

      prometheus = {
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

      nginx = {
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
    };
    nixpkgs.config.allowUnfree = true;
    boot.binfmt.emulatedSystems = ["aarch64-linux"];
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

  android.enable = true;
  display.greetd.enable = false;
  display.greetd.command = lib.mkMerge [
    (lib.mkIf (builtins.hasAttr "vmgpu" config.os.specialisation) "offload-igpu Hyprland")
    (lib.mkIf (!builtins.hasAttr "vmgpu" config.os.specialisation) "offload-gpu Hyprland")
  ];

  # # Enable the COSMIC login manager
  # os.services.displayManager.cosmic-greeter.enable = true;

  # # Enable the COSMIC desktop environment
  # os.services.desktopManager.cosmic.enable = true;

  # TCP: 47984, 47989, 48010
  # UDP: 47998-48000, 48002, 48010

  # networking.allowedPorts.tcp."5556" = ["ope.lan1" "0.0.0.0"];
  # networking.forwardPorts = {
  #   "127.0.0.1" = {
  #     tcp = ["5556"];
  #     masquerade = true;
  #   };
  # };
  # networking.allowedPorts.tcp."51797" = ["0.0.0.0"];
  # networking.allowedPorts.udp."51797" = ["0.0.0.0"];
  # networking.vpnNamespace.vpn.ports.tcp = ["51797"];
  # networking.vpnNamespace.vpn.ports.udp = ["51797"];

  # networking.allowedPorts.tcp."47984,47989,48010" = [(getHostname "ope.wg_private")];
  # networking.allowedPorts.udp."47998-48000" = [(getHostname "ope.wg_private")];
  # networking.allowedPorts.udp."48002,48010" = [(getHostname "ope.wg_private")];

  display.hyprland = {
    enable = false;
    headlessXorg.enable = true;
    monitors = lib.mkMerge [
      [
        "eDP-1,disable"
        "HDMI-A-1,1920x1080@60,0x0,1"
        "HDMI-A-1,addreserved,0,24,0,0"
      ]
      (lib.mkIf (builtins.hasAttr "vmgpu" config.os.specialisation) ["HDMI-A-2,disable"])
      (lib.mkIf (!builtins.hasAttr "vmgpu" config.os.specialisation) ["HDMI-A-2,1920x1080@60,0x0,1" "HDMI-A-2,addreserved,0,24,0,0"])
    ];
  };
  fonts.enable = true;
  printers.enable = true;

  bitwarden.enable = true;

  assets.enable = true;

  # networking.enable = true;

  secrets.enable = true;

  themes.themeName = "amoled";

  vm.enable = true;
  games.enable = true;
  gtk.enable = true;

  programs = {
    # anyrun.enable = true;
    firefox.enable = true;
    gnome.enable = true;
    mpv.enable = true;
    # vscode.enable = true;
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
    # discord.enable = true;
    gui-utils.enable = true;
  };

  os.programs.nix-ld.enable = true;
  os.programs.nix-ld.libraries = with pkgs; [
    # List common libraries binaries often look for
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    # Add GTK/system libs since Electrobun needs them
    gtk3
    glib
    webkitgtk_4_1.out
    cairo
    gtk3
    libayatana-appindicator
    libsoup_3
    gdk-pixbuf.out
  ];

  os.networking.extraHosts = ''
    ${resolveHostname "mane.wg_vps"} mane
    ${resolveHostname "mera.home"} mera
    127.0.0.1 ope
  '';

  os.hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Optional but recommended
    extraPackages = with pkgs; [
      rocmPackages.clr          # Core ROCm runtime (HIP)
      rocmPackages.rocblas
      rocmPackages.hipblas
      rocmPackages.rocm-smi     # For monitoring
      rocmPackages.rocminfo     # For verification
    ];
  };

  # os.specialisation.vmgpu = {
  #
  # };
}
