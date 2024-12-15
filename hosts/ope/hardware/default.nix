{
  pkgs,
  osConfig,
  lib,
  inputs,
  config,
  ...
}: let
  newMesa = pkgs.mesa.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./mesa.patch];
  });
in {
  osModules = [
    ./hardware-configuration.nix
  ];

  vm.gpu = ["1002:73df" "1002:ab28"];

  os = {
    # system.replaceRuntimeDependencies = [
    #   {
    #     original = pkgs.mesa;
    #     replacement = newMesa;
    #   }
    #   {
    #     original = pkgs.mesa.drivers;
    #     replacement = newMesa.drivers;
    #   }
    # ];

    environment.systemPackages = let
      offload-gpu = pkgs.writeShellScriptBin "offload-gpu" ''
        export DRI_PRIME="pci-0000_03_00_0"
        export WLR_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:03:00.0-card")
        export AQ_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:03:00.0-card")
        exec "$@"
      '';
      offload-igpu = pkgs.writeShellScriptBin "offload-igpu" ''
        export DRI_PRIME="pci-0000_12_00_0"
        export WLR_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:12:00.0-card")
        export AQ_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:12:00.0-card")
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

        # Put the system to sleep for 6 seconds
        if [ $# -lt 2 ]; then
          rtcwake -m mem -s 6
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
    # i18n.extraLocaleSettings = {
    #   # LC_ADDRESS = "en_IL";
    #   # LC_IDENTIFICATION = "en_IL";
    #   # LC_MEASUREMENT = "en_IL";
    #   # LC_MONETARY = "en_IL";
    #   # LC_NAME = "en_IL";
    #   # LC_NUMERIC = "en_IL";
    #   # LC_PAPER = "en_IL";
    #   # LC_TELEPHONE = "en_IL";
    #   # LC_TIME = "en_IL";
    #
    #   "LANG" = "en_IL";
    #   "LC_CTYPE" = "en_IL";
    #   "LC_NUMERIC" = "en_IL";
    #   "LC_TIME" = "en_IL";
    #   "LC_COLLATE" = "en_IL";
    #   "LC_MONETARY" = "en_IL";
    #   "LC_MESSAGES" = "en_IL";
    #   "LC_PAPER" = "en_IL";
    #   "LC_NAME" = "en_IL";
    #   "LC_ADDRESS" = "en_IL";
    #   "LC_TELEPHONE" = "en_IL";
    #   "LC_MEASUREMENT" = "en_IL";
    #   "LC_IDENTIFICATION" = "en_IL";
    #   "LC_ALL=" = "en_IL";
    # };

    # Networking
    environment.etc."resolv.conf".text = ''
      nameserver 9.9.9.9
      nameserver 1.1.1.1
      nameserver 8.8.8.8
    '';

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
      # kernelPackages = pkgs.linuxPackages_6_9;
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

    boot.kernelModules = ["v4l2loopback"];
    boot.extraModulePackages = [
      osConfig.boot.kernelPackages.v4l2loopback.out
    ];
    # Set initial kernel module settings
    boot.extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Camera 1"
    '';
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
      opengl = {
        # package = newMesa.drivers;
        enable = true;
        # driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
    };
  };

  os.system.stateVersion = "23.05";
  hm.home.stateVersion = "23.05";
}
