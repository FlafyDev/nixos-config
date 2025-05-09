{
  pkgs,
  osConfig,
  lib,
  inputs,
  ...
}:{
  osModules = [
    ./hardware-configuration.nix
  ];

  unfree.allowed = ["nvidia-x11" "nvidia-settings" "nvidia-persistenced"];

  os = {
    environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";

    time.timeZone = "Israel";
    boot = {
      kernelPackages = pkgs.linuxPackages_6_1;
      blacklistedKernelModules = ["nouveau"];
      supportedFilesystems = ["ntfs"];
      loader = {
        systemd-boot.enable = true;
        efi = {
          canTouchEfiVariables = true;
        };
        # grub = {
        #   enable = true;
        #   devices = ["nodev"];
        #   efiSupport = true;
        #   useOSProber = true;
        # };
      };
    };

    services.upower.enable = true;
    services.logind.lidSwitch = "ignore";
    # environment.etc."resolv.conf".text = ''
    #   nameserver 9.9.9.9
    #   nameserver 1.1.1.1
    #   nameserver 8.8.8.8
    # '';

    boot.kernelParams = [
      # "nouveau.modeset=1"
      "video=HDMI-A-1:1920x1080@60"
      "nohibernate"
    ];

    hardware.nvidia = {
      open = false;
      modesetting.enable = false;
      powerManagement = {
        enable = false;
        # finegrained = true;
      };
      nvidiaSettings = false;
      nvidiaPersistenced = false;
      forceFullCompositionPipeline = false;
      package = osConfig.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload.enable = false;
        offload.enableOffloadCmd = false;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    # services.xserver = {
    #   videoDrivers = ["nvidia"];
    #   # deviceSection = ''
    #   #   Option "DRI" "2"
    #   #   Option "TearFree" "true"
    #   # '';
    # };

    # specialisation = {
    #   nvidiaSync.configuration = {
    #     hardware.nvidia.prime.sync.enable = lib.mkForce true;
    #   };
    # };

    hardware = {
      # bumblebee.enable = true;
      pulseaudio.enable = false;
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
      # opentabletdriver.enable = true;

      graphics = {
        enable = true;
        # driSupport = true;
        # enable32Bit = true;
        # extraPackages = with pkgs; [nvidia-vaapi-driver];
        # extraPackages32 = with pkgs.pkgsi686Linux; [nvidia-vaapi-driver];
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
