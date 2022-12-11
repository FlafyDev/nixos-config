{
  systemType = "x86_64-linux";

  # add = {nixpkgs-stable, ...}: {
  #   overlays = _: let
  #     pkgs-stable = import nixpkgs-stable {
  #       system = "x86_64-linux";
  #     };
  #   in [
  #     (_final: prev: {
  #       inherit (pkgs-stable) pipewire;
  #     })
  #   ];
  # };

  system = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [
      ./hardware-configuration.nix
    ];

    sound.enable = false;

    nixpkgs.config.allowUnfree = true;

    # specialisation = {
    #   external-display.configuration = {
    #     system.nixos.tags = [ "external-display" ];
    #     hardware.nvidia.prime.offload.enable = lib.mkForce false;
    #     hardware.nvidia.powerManagement.enable = lib.mkForce false;
    #   };
    # };

    systemd.services.NetworkManager-wait-online.enable = false;

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      # kernelPatches = [
      #   {
      #     name = "nouveau-try";
      #     patch = null;
      #     extraConfig = ''
      #       CONFIG_FRAMEBUFFER_CONSOLE y
      #     '';
      #   }
      # ];
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
      supportedFilesystems = ["ntfs"];
    };

    fileSystems."/mnt/general" = {
      device = "/dev/disk/by-uuid/23e60b41-48d2-4b32-8cc8-bf52e0b305f4";
      fsType = "ext4";
    };

    networking = {
      hostName = "nixos";
      networkmanager = {
        enable = true;
        insertNameservers = [ "1.1.1.1" ];
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
        enable = false;
        allowedTCPPorts = [];
        allowedUDPPorts = [];
      };
    };

    # boot.kernelParams = ["nouveau.modeset=1"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      prime = {
        offload.enable = true;
        sync.enable = false;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      package = config.boot.kernelPackages.nvidiaPackages.latest;
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
        hsphfpd.enable = true;
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
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiVdpau
          libvdpau-va-gl
        ];
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
      pipewire = {
        enable = true;
        alsa.enable = true;
        wireplumber.enable = true;
        pulse.enable = true;
      };

      openssh.enable = true;
      # blueman.enable = true;
    };

    system.stateVersion = "22.05";
  };

  home = _: {
    home.stateVersion = "22.05";
  };
}
