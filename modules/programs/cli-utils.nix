{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.cli-utils;
in {
  options.programs.cli-utils = {
    enable = mkEnableOption "cli-utils";
  };

  config = let
    updateSystem = pkgs.writeShellScript "updateSystem" ''
      case $2 in
        fast)
          nixos-rebuild test --fast --flake .?submodules=1#$1 --impure -L "''${@:3}"
          ;;
        boot)
          nixos-rebuild boot --flake .?submodules=1#$1 "''${@:3}"
          ;;
        *)
          nixos-rebuild switch --flake .?submodules=1#$1 "''${@:2}"
          ;;
      esac
    '';
    configLocation = "/home/flafydev/.dotfiles/system";
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '';
    wifi = pkgs.writeShellScriptBin "wifi" ''
      case $1 in
        list)
          nmcli dev wifi
          ;;
        connect)
          nmcli dev wifi connect "$2" password "$3"
          ;;
        disable)
          nmcli radio wifi off
          ;;
        enable)
          nmcli radio wifi on
          ;;
        delete)
          nmcli connection delete id $2
          ;;
        *)
          echo "list"
          echo "connect <id> <pass>"
          echo "disable"
          echo "enable"
          echo "delete <id>"
          ;;
      esac
    '';
    makeConfigEditable = pkgs.writeShellScriptBin "makeConfigEditable" ''
      newName="$1-$(date +%s)"
      mv ./$1 ./''${newName}
      cat ''${newName} > ./$1
    '';
    update = pkgs.writeShellScriptBin "update" ''(cd ${configLocation} ; sudo ${updateSystem} laptop "$@")'';
    updateBoot = pkgs.writeShellScriptBin "update-boot" ''(cd ${configLocation} ; sudo ${updateSystem} laptop boot "$@")'';
    updateFast = pkgs.writeShellScriptBin "update-fast" ''(cd ${configLocation} ; sudo ${updateSystem} laptop fast "$@")'';
  in
    mkIf cfg.enable {
      sys.environment.systemPackages = with pkgs; [
        update
        updateBoot
        updateFast
        nvidia-offload
        makeConfigEditable
        wifi

        nano
        wget
        parted
        neofetch
        unzip
        xclip
        bat
        exa
        service-wrapper
        distrobox
        wl-clipboard
        drm_info
        # lang-to-docx
        htop
        tree
        # cp-maps
        # project-creator
        vdpauinfo
        pciutils
        binutils
        intel-gpu-tools
        libva-utils
        # nur.repos.mic92.noise-suppression-for-voice
      ];
    };
}
