{
  pkgs,
  osConfig,
  lib,
  inputs,
  ...
}: {
  osModules = [
    ./hardware-configuration.nix
  ];

  vm.gpu = ["1002:73df" "1002:ab28"];

  # inputs = {
  #   nixos-old-stable.url = "github:nixos/nixpkgs/b3a285628a6928f62cdf4d09f4e656f7ecbbcafb";
  # };

  os = {
    # system.replaceRuntimeDependencies = let
    #   oldPkgs = import inputs.nixos-old-stable {inherit (pkgs) system;};
    # in [
    #   {
    #     original = pkgs.mesa;
    #     replacement = oldPkgs.mesa;
    #   }
    #   {
    #     original = pkgs.mesa.drivers;
    #     replacement = oldPkgs.mesa.drivers;
    #   }
    # ];

    environment.systemPackages = let
      offload-gpu = pkgs.writeShellScriptBin "offload-gpu" ''
        export DRI_PRIME="pci-0000_03_00_0"
        export WLR_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:03:00.0-card")
        exec "$@"
      '';
      offload-igpu = pkgs.writeShellScriptBin "offload-igpu" ''
        export DRI_PRIME="pci-0000_12_00_0"
        export WLR_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:12:00.0-card")
        exec "$@"
      '';
      gpu-rebind = pkgs.writeShellScriptBin "gpu-rebind" ''
        if [[ $EUID -ne 0 ]]; then
            echo "This script must be run as root."
            exit 1
        fi

        if [[ $# -lt 1 ]]; then
            echo "Usage: $0 <new_driver>"
            exit 1
        fi

        new_driver="$1"
        gpu="0000:03:00.0"

        # Function to unbind GPU from the current driver
        unbind_gpu() {
            local gpu_id="$1"
            local current_driver=$(basename $(readlink /sys/bus/pci/devices/''${gpu_id}/driver))

            if [[ "$current_driver" != "$new_driver" ]]; then
                echo "Unbinding GPU $gpu_id from driver $current_driver..."
                echo "$gpu_id" > /sys/bus/pci/drivers/''${current_driver}/unbind
            else
                echo "GPU $gpu_id is already using driver $current_driver."
            fi
        }

        # Function to bind GPU to the new driver
        bind_gpu() {
            local gpu_id="$1"
            local current_driver=$(basename $(readlink /sys/bus/pci/devices/''${gpu_id}/driver))

            if [[ "$current_driver" != "$new_driver" ]]; then
                echo "Binding GPU $gpu_id to driver $new_driver..."
                echo "$gpu_id" > /sys/bus/pci/drivers/''${new_driver}/bind
            else
                echo "GPU $gpu_id is already using driver ''$new_driver."
            fi
        }

        # Unbind GPU if necessary
        unbind_gpu "$gpu"

        # Put the system to sleep for 3 seconds
        if [ $# -lt 2 ]; then
          rtcwake -m mem -s 3
        fi

        # Wait for another 3 seconds
        sleep 3

        # Bind GPU to the new driver
        bind_gpu "$gpu"

        echo "Script execution completed."
      '';
    in
      with pkgs; [
        vulkan-validation-layers
        offload-gpu
        offload-igpu
        gpu-rebind
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
      firewall = {
        enable = false;
        allowedUDPPorts = [53317];
        allowedTCPPorts = [53317];
      };
      hostName = "ope";
      interfaces.enp14s0.wakeOnLan.enable = true;
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
      kernelPackages = pkgs.linuxPackages_latest;
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
      # "amdgpu.sg_display=0"
      "video=HDMI-A-1:1920x1080@60"
      "video=HDMI-A-2:1920x1080@60"
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
      # opengl = {
      #   enable = true;
      #   driSupport = true;
      #   driSupport32Bit = true;
      #   extraPackages = with pkgs; [
      #     vaapiVdpau
      #     libvdpau-va-gl
      #   ];
      # };
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
