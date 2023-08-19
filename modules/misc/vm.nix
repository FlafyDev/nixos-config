{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.vm;
  inherit (lib) mkEnableOption mkIf types mkOption;
  # gpuIDs = [
  #   # "1002:73df"
  #   # "1002:ab28"
  #   "03:00.0"
  #   "03:00.1"
  # ];
  load-vm = pkgs.writeShellScriptBin "load-vm" ''
    export DRI_PRIME="pci-0000_03_00_0"
    export WLR_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:03:00.0-card")
    exec "$@"
  '';
  unload-vm = pkgs.writeShellScriptBin "unload-vm" ''
    export DRI_PRIME="pci-0000_03_00_0"
    export WLR_DRM_DEVICES=$(readlink -f "/dev/dri/by-path/pci-0000:03:00.0-card")
    exec "$@"
  '';
in {
  options.vm = {
    enable = mkEnableOption "vm";
    vmGPUIPCs = mkOption {
      type = with types; listOf str;
      description = "The IPCs related to the DGPU";
    };
  };

  config = mkIf cfg.enable {
    users.groups = ["libvirtd" "vboxusers"];
    os = {
      boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        "kvmfr"
        # "vendor-reset"
      ];
      # boot.initrd.availableKernelModules = [ "vendor-reset" ];

      # boot.initrd.preDeviceCommands = ''
      #   DEVS='${lib.concatStringsSep " " gpuIDs}'
      #   for DEV in $DEVS; do
      #       echo 'none' > /sys/bus/pci/devices/0000:"$DEV"/driver_override
      #   done
      # '';
      boot.kernelParams = [
        "amd_iommu=on"
        # TODO don't hardcode
        "vfio-pci.ids=1002:73df,1002:ab28"
        "iommu=pt"
        "video=efifb:off"

        # "early_load_vfio"

        # ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs)
      ];
      services.udev.extraRules = ''
        SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", OWNER="flafy", GROUP="kvm", MODE="0660"
      '';
      boot.extraModprobeConfig = ''
        options kvm ignore_msrs=1
        options kvmfr static_size_mb=32
        options snd_hda_intel power_save=0
      '';
      boot.extraModulePackages = [
        # osConfig.boot.kernelPackages.vendor-reset
        (osConfig.boot.kernelPackages.kvmfr.overrideAttrs (old: {
          inherit (pkgs.looking-glass-client) version src;
        }))
      ];

      # systemd.tmpfiles.rules = [
      #   "f /dev/shm/looking-glass 0660 flafy qemu-libvirtd -"
      # ];
      # boot.extraModprobeConfig = "options kvm_amd nested=1";

      environment.systemPackages = with pkgs; [
        virt-manager
        looking-glass-client
      ];

      # boot.kernelPatches = [
      #   {
      #     name = "vendor-reset";
      #     patch = null;
      #     extraConfig = ''
      #       FTRACE y
      #       KPROBES y
      #       PCI_QUIRKS y
      #       KALLSYMS y
      #       KALLSYMS_ALL y
      #       FUNCTION_TRACER y
      #     '';
      #   }
      # ];

      virtualisation.virtualbox.host.enable = true;
      users.extraGroups.vboxusers.members = ["user-with-access-to-virtualbox"];

      virtualisation.docker.enable = true;
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          ovmf.enable = true;
          # Full is needed for TPM and secure boot emulation
          # ovmf.packages = [ pkgs.OVMFFull.fd ];
          # TPM emulation
          # swtpm.enable = true;
          verbatimConfig = ''
            cgroup_device_acl = [
              "/dev/kvmfr0",
              "/dev/vfio/vfio", "/dev/vfio/11", "/dev/vfio/12",
              "/dev/null", "/dev/full", "/dev/zero",
              "/dev/random", "/dev/urandom",
              "/dev/ptmx", "/dev/kvm"
            ]
          '';
          # might disable this later
          # runAsRoot = true;
        };
      };

      # extraModulePackages = [
      #   osConfig.boot.kernelPackages.kvmfr
      # ];
    };
  };
}
