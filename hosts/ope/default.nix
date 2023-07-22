{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  osModules = [
    ./hardware-configuration.nix
  ];

  os = {
    environment.systemPackages = with pkgs; [
      vulkan-validation-layers
    ];

    # Time and locale
    time.timeZone = "Asia/Jerusalem";
    i18n.defaultLocale = "en_IL";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "he_IL.UTF-8";
      LC_IDENTIFICATION = "he_IL.UTF-8";
      LC_MEASUREMENT = "he_IL.UTF-8";
      LC_MONETARY = "he_IL.UTF-8";
      LC_NAME = "he_IL.UTF-8";
      LC_NUMERIC = "he_IL.UTF-8";
      LC_PAPER = "he_IL.UTF-8";
      LC_TELEPHONE = "he_IL.UTF-8";
      LC_TIME = "he_IL.UTF-8";
    };

    # Networking
    networking = {
      hostName = "ope";
      networkmanager = {
        enable = true;
        # insertNameservers = ["1.1.1.1"];
      };
    };

    # Audio
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    boot = {
      kernelPackages = pkgs.linuxPackages_6_3;
      supportedFilesystems = ["ntfs"];
      loader = {
        # systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          devices = ["nodev"];
          efiSupport = true;
          useOSProber = true;
        };
      };
    };

    services.upower.enable = true;

    boot.kernelParams = [
      "video=HDMI-A-1:1920x1080@60"
    ];

    hardware = {
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
        driSupport = true;
        driSupport32Bit = true;
      };
    };

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
      tlp = {
        enable = false;
      };
    };
  };

  os.system.stateVersion = "23.05";
  hm.home.stateVersion = "23.05";
}
