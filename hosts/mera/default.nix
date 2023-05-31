{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  osModules = [
    ./hardware-configuration.nix
  ];

  unfree.allowed = ["nvidia-x11" "nvidia-settings"];

  os = {
    time.timeZone = "Israel";
    networking.hostName = "mera";
    # systemd.services.NetworkManager-wait-online.enable = false;
    boot = {
      kernelPackages = pkgs.linuxPackages_6_1;
      # blacklistedKernelModules = ["nouveau"];
      supportedFilesystems = ["ntfs"];
      # kernelPatches = [
      #   {
      #     name = "nouveau-try";
      #     patch = null;
      #     extraConfig = ''
      #       CONFIG_FRAMEBUFFER_CONSOLE y
      #     '';
      #   }
      # ];
      plymouth = {
        enable = true;
      };
      loader = {
        # systemd-boot.enable = true;
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot/efi";
        };
        grub = {
          enable = true;
          version = 2;
          devices = ["nodev"];
          efiSupport = true;
          useOSProber = true;
        };
      };
    };

    services.upower.enable = true;

    networking = {
      networkmanager = {
        enable = true;
        insertNameservers = ["1.1.1.1"];
      };

      dhcpcd = {
        wait = "background";
        extraConfig = "noarp";
      };

      useDHCP = false;
      interfaces = {
        wlp3s0.useDHCP = true;
        enp4s0.useDHCP = true;
      };

      firewall = {
        enable = true;
        allowedTCPPorts = [58846];
        allowedUDPPorts = [58846];
      };
    };

    boot.kernelParams = [
      # "nouveau.modeset=1"
      "video=HDMI-A-1:1920x1080@60"
    ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      package = osConfig.boot.kernelPackages.nvidiaPackages.latest;
    };
    services.xserver = {
      videoDrivers = ["nvidia"];
      # deviceSection = ''
      #   Option "DRI" "2"
      #   Option "TearFree" "true"
      # '';
    };

    # specialisation = {
    #   nvidiaSync.configuration = {
    #     hardware.nvidia.prime.sync.enable = lib.mkForce true;
    #   };
    # };

    hardware = {
      # bumblebee.enable = true;
      pulseaudio.enable = lib.mkForce false;
      # pulseaudio.enable = true;
      bluetooth = {
        enable = true;
        hsphfpd.enable = false;
        # package = pkgs.bluez;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };
      opentabletdriver.enable = true;

      opengl = {
        enable = true;
        # extraPackages = with pkgs; [
        #   intel-media-driver
        #   # vaapiIntel
        #   vaapiVdpau
        #   libvdpau-va-gl
        # ];
        # setLdLibraryPath = true;
        # driSupport = true;
        # extraPackages = with pkgs; [
        #   libglvnd
        #   intel-media-driver
        #   vaapiVdpau
        #   vaapi-intel-hybrid
        #   vaapiIntel
        #   libvdpau-va-gl
        #   nvidia-vaapi-driver
        #   libva
        # ];
      };
    };

    # wake up on external usb devices
    # powerManagement.powerDownCommands = ''
    #   echo enabled > /sys/bus/usb/devices/usb1/power/wakeup
    #   echo enabled > /sys/bus/usb/devices/usb2/power/wakeup
    # '';

    # specialisation = {
    #   external-display.configuration = {
    #     system.nixos.tags = [ "external-display" ];
    #     hardware.nvidia.prime.offload.enable = lib.mkForce false;
    #     hardware.nvidia.powerManagement.enable = lib.mkForce false;
    #   };
    # };

    programs.light.enable = false;

    security = {
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

    services = {
      # pipewire = {
      #   enable = true;
      #   # alsa.enable = true;
      #   # pulse.enable = true;
      #   # media-session.enable = true;
      #   wireplumber.enable = true;
      #   # If you want to use JACK applications, uncomment this
      #   #jack.enable = true;
      # }
      tlp = {
        enable = false;
      };

      pipewire = {
        enable = true;
        alsa.enable = true;
        jack.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      # openssh.enable = true;
      # blueman.enable = true;
    };
  };

  os.system.stateVersion = "23.05";
  hm.home.stateVersion = "23.05";
}
