{ config, lib, pkgs, modulesPath, ... }:

let 
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in 
{
  sound.enable = true;

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
    opengl.enable = true;
    pulseaudio.enable = true;
    
    nvidia = {
      modesetting.enable = true;
      prime = {
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # wake up on external usb devices
  powerManagement.powerDownCommands = ''
    echo enabled > /sys/bus/usb/devices/usb1/power/wakeup
    echo enabled > /sys/bus/usb/devices/usb2/power/wakeup
  '';

  environment.systemPackages = [
    nvidia-offload
  ];

  services = {
    openssh.enable = true;

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
  };

  system.stateVersion = "21.11";
}