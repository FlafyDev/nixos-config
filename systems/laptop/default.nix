{
  systemType = "x86_64-linux";

  system = { pkgs, config, lib, ... }: {
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

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      loader = {
        # systemd-boot.enable = true;
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot/efi";
        };
        grub = {
          enable = true;
          version = 2;
          devices = [ "nodev" ];
          efiSupport = true;
          useOSProber = true;
        };
      };
      supportedFilesystems = [ "ntfs" ];
    };

    fileSystems."/mnt/general" = {
      device = "/dev/disk/by-uuid/23e60b41-48d2-4b32-8cc8-bf52e0b305f4";
      fsType = "ext4";
    };

    networking = {
      hostName = "nixos";
      networkmanager.enable = true;

      useDHCP = false;
      interfaces = {
        wlp3s0.useDHCP = true;
        enp4s0.useDHCP = true;
      };

      firewall = {
        enable = false;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };
    };

    hardware = {
      bluetooth = {
        enable = true;
        hsphfpd.enable = true;
        package = pkgs.bluezFull;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };
      opentabletdriver.enable = true;
      pulseaudio.enable = false;
      
      nvidia = {
        modesetting.enable = true;
        prime = {
          offload.enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };

      opengl = {
        enable = true;
        # driSupport = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          nvidia-vaapi-driver
        ];
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

    security.rtkit.enable = true;
    programs.light.enable = true;

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;
      };

      openssh.enable = true;
      blueman.enable = true;
      
      xserver = {
        videoDrivers = [ "nvidia" ];
        # deviceSection = ''
        #   Option "DRI" "2"
        #   Option "TearFree" "true"
        # '';
      };
    };

    system.stateVersion = "22.05";
  };

  home = { pkgs, lib, ... }: {
    home.stateVersion = "22.05";
  };
}
