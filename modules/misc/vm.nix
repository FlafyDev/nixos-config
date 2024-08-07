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
      nixpkgs.overlays = [
        (_final: prev: {
          looking-glass-client = prev.looking-glass-client.overrideAttrs (_old: rec {
            version = "B6";
            patches = [];
            src = prev.fetchFromGitHub {
              owner = "gnif";
              repo = "LookingGlass";
              rev = version;
              sha256 = "sha256-6vYbNmNJBCoU23nVculac24tHqH7F4AZVftIjL93WJU=";
              fetchSubmodules = true;
            };
          });
        })
      ];
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
          patches = [
            ./vm-temp.patch
          ];
          # patches = []; # UPDATE-TODO: https://github.com/NixOS/nixpkgs/pull/305018
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
        # hooks.qemu = {
        #   "passthrough" = lib.getExe (
        #     pkgs.writeShellApplication {
        #       name = "qemu-hook";
        #
        #       runtimeInputs = with pkgs; [
        #         libvirt
        #         systemd
        #         kmod
        #       ];
        #
        #       text = ''
        #         GUEST_NAME="$1"
        #         OPERATION="$2"
        #
        #         if [ "$GUEST_NAME" != "win-gpu" ]; then
        #           exit 0;
        #         fi
        #
        #         if [ "$OPERATION" == "prepare" ]; then
        #           echo "0000:03:00.0" > /sys/bus/pci/drivers/amdgpu/unbind || true
        #           echo "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/bind || true
        #         fi
        #
        #         if [ "$OPERATION" == "release" ]; then
        #           echo "0000:03:00.0" > /sys/bus/pci/drivers/vfio-pci/unbind || true
        #           echo "0000:03:00.0" > /sys/bus/pci/drivers/amdgpu/bind || true
        #         fi
        #       '';
        #     }
        #   );
        # };
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
