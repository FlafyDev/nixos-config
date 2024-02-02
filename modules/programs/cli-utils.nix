{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.cli-utils;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.cli-utils = {
    enable = mkEnableOption "cli-utils";
  };

  config = let
    build-system = pkgs.writeShellScriptBin "build-system" ''
      while [ "$#" -gt 0 ]; do
        i="$1"; shift 1
        case "$i" in
          --op)
            operation="$1"
            shift 1
            ;;
          --host)
            host="$1"
            shift 1
            ;;
          --custom)
            custom="$1"
            shift 1
            ;;
        esac
      done

      if [ ! -z "$host" ]; then
        case $host in
          "bara")
            ssh_host="bara.lan1.flafy.me"
            ;;
          "mera")
            ssh_host="mera.lan1.flafy.me"
            ;;
          "mane")
            ssh_host="flafy.me"
            ;;
          "ope")
            exit 1
            ;;
          *)
            exit 1
            ;;
        esac

        nixos-rebuild $operation --flake .#$host --option eval-cache false -L -v --target-host root@$ssh_host $custom |& ${pkgs.nix-output-monitor}/bin/nom
      else
        sudo nixos-rebuild $operation --flake .# --option eval-cache false -L -v $custom |& ${pkgs.nix-output-monitor}/bin/nom
      fi
    '';
    configLocation = "/mnt/general/repos/flafydev/nixos-config";
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
  in
    mkIf cfg.enable {
      unfree.allowed = ["unrar"];
      os.environment.systemPackages = with pkgs; let
        bin = writeShellScriptBin;
      in [
        (bin "fl" ''${eza}/bin/eza -lga "$@"'') 
        (bin "batp" ''${bat}/bin/bat -P "$@"'') 
        (bin "cpwd" "pwd | wl-copy") 

        build-system
        nvidia-offload
        makeConfigEditable
        wifi

        jq
        nano
        wget
        parted
        neofetch
        unzip
        xclip
        bat
        eza
        service-wrapper
        distrobox
        usbutils
        wl-clipboard
        drm_info
        # lang-to-docx
        ripgrep
        htop
        tree
        # cp-maps
        # project-creator
        btop
        wf-recorder
        libnotify
        xdg-utils
        slurp
        vdpauinfo
        pciutils
        binutils
        intel-gpu-tools
        libva-utils
        ffmpeg
        unrar
        # nur.repos.mic92.noise-suppression-for-voice
      ];
    };
}
