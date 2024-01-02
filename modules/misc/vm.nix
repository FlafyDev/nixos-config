{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.vm;
  inherit (lib) mkEnableOption mkIf types mkOption concatStringsSep;
in {
  options.vm = {
    enable = mkEnableOption "vm";
    gpu = mkOption {
      type = with types; listOf str;
      example = ''["1002:73df" "1002:ab28"]'';
      description = ''
        The IPCs related to the GPU to pass.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.groups = ["libvirtd"];
    os = {
      boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        "kvmfr"
      ];

      boot.kernelParams = [
        "amd_iommu=on"
        "vfio-pci.ids=${concatStringsSep "," cfg.gpu}"
        "iommu=pt"
        "video=efifb:off"
      ];

      services.udev.extraRules = ''
        SUBSYSTEM=="kvmfr", KERNEL=="kvmfr0", OWNER="${config.users.main}", GROUP="kvm", MODE="0660"
      '';

      boot.extraModprobeConfig = ''
        options kvm ignore_msrs=1
        options kvmfr static_size_mb=32
        options snd_hda_intel power_save=0
      '';

      boot.extraModulePackages = [
        (osConfig.boot.kernelPackages.kvmfr.overrideAttrs (old: {
          inherit (pkgs.looking-glass-client) version src;
        }))
      ];

      environment.systemPackages = with pkgs; [
        virt-manager
        looking-glass-client
        guestfs-tools
      ];

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
        };
      };
    };
  };
}
