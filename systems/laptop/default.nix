{
  systemType = "x86_64-linux";

  system = { pkgs, config, ... }: {
    imports = [
      ./hardware-configuration.nix
    ];

    sound.enable = false;

    nixpkgs.config.allowUnfree = true;

    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        grub = {
          devices = [ "nodev" ];
          efiSupport = true;
          enable = true;
          extraEntries = ''
            menuentry "Windows" {
              insmod part_gpt
              insmod fat
              insmod search_fs_uuid
              insmod chain
              search --fs-uuid --set=root 4424-E13F
              chainloader /EFI/Microsoft/Boot/bootmgfw.efi
            }
          '';
          version = 2;
        };
      };
      supportedFilesystems = [ "ntfs" ];
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
      bluetooth.enable = true;
      opentabletdriver.enable = true;
      pulseaudio.enable = false;
      
      nvidia = {
        modesetting.enable = true;
        prime = {
          sync.enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };

      opengl = {
        enable = true;
        driSupport = true;
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
    powerManagement.powerDownCommands = ''
      echo enabled > /sys/bus/usb/devices/usb1/power/wakeup
      echo enabled > /sys/bus/usb/devices/usb2/power/wakeup
    '';
    
    # specialisation = {
    #   external-display.configuration = {
    #     system.nixos.tags = [ "external-display" ];
    #     hardware.nvidia.prime.offload.enable = lib.mkForce false;
    #     hardware.nvidia.powerManagement.enable = lib.mkForce false;
    #   };
    # };

    security.rtkit.enable = true;

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
      };
    };

    system.stateVersion = "21.11";
  };

  home = { pkgs, lib, ... }: let
    patchDesktop = pkg: appName: from: to: lib.hiPrio (pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
      ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
      ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
    '');
  in {
    home.packages = [
      (
        patchDesktop pkgs.chromium "chromium-browser"
        "^Exec=chromium" "Exec=nvidia-offload chromium -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder"
      )
      (
        patchDesktop pkgs.firefox "firefox"
        "^Exec=firefox" "Exec=env MOZ_ENABLE_WAYLAND=1 nvidia-offload firefox"
      )
      (patchDesktop pkgs.mpv-unwrapped "mpv" "^Exec=mpv" "Exec=nvidia-offload mpv")
      (patchDesktop pkgs.webcord "webcord" "^Exec=webcord" "Exec=nvidia-offload webcord -enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=VaapiVideoDecoder")
    ];

    home.stateVersion = "21.11";
  };
}
