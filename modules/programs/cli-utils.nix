{
  lib,
  config,
  pkgs,
  utils,
  ...
}: let
  cfg = config.programs.cli-utils;
  inherit (lib) mkEnableOption mkIf;
  inherit (utils) getHostname domains resolveHostname;
in {
  options.programs.cli-utils = {
    enable = mkEnableOption "cli-utils";
  };

  config = let
    f-util = pkgs.writeShellScriptBin "f" ''
      case "$1" in
        rb)
          while [ "$#" -gt 0 ]; do
            i="$2"; shift 1
            case "$i" in
              --op|-o)
                operation="$1"
                shift 1
                ;;
              --host|-h)
                host="$1"
                shift 1
                ;;
              --custom|-c)
                custom="$1"
                shift 1
                ;;
            esac
          done

          if [ ! -z "$host" ]; then
            case $host in
              "bara")
                ssh_host="${getHostname "bara.home"}"
                ;;
              "mera")
                ssh_host="${getHostname "mera.home"}"
                ;;
              "mane")
                ssh_host="${resolveHostname domains.personal}"
                ;;
              "ope")
                exit 1
                ;;
              *)
                exit 1
                ;;
            esac

            sudo -E -u flafy nixos-rebuild $operation --flake .#$host --option eval-cache false -L --target-host root@$ssh_host $custom |& ${pkgs.nix-output-monitor}/bin/nom
          else
            sudo nixos-rebuild $operation --flake .# --option eval-cache false -L $custom |& ${pkgs.nix-output-monitor}/bin/nom
          fi
          ;;
        secret)
          env -C /home/flafy/repos/flafydev/nixos-config/secrets agenix -e $2 -i /home/flafy/.ssh/agenix
          ;;
        scode)
          export PORT="''${PORT:-$((RANDOM % 801 + 8100))}" # Random port between 8100 and 8900 if PORT isn't set
          export EXTENSIONS_GALLERY='{
            "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
            "itemUrl": "https://marketplace.visualstudio.com/items",
            "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
            "controlUrl": "",
            "recommendationsUrl": ""
          }'

          printf "Run locally:\nf ocode $PORT $PWD\n\n"
          export EDITOR="${pkgs.code-server}/libexec/code-server/lib/vscode/bin/remote-cli/code-linux.sh --wait"

          if [[ "$2" == "waypipe" ]]; then
            rm /tmp/waypipe.sock || true
            ${pkgs.socat}/bin/socat UNIX-LISTEN:/tmp/waypipe.sock,reuseaddr,fork TCP:10.10.11.14:12345
            ${pkgs.waypipe}/bin/waypipe -s /tmp/waypipe.sock server -- ${pkgs.code-server}/bin/code-server --bind-addr 0.0.0.0:$PORT --auth none $PWD
          else
            ${pkgs.code-server}/bin/code-server --bind-addr 0.0.0.0:$PORT --auth none $PWD
          fi
          ;;
        ocode)
          export PORT=$2
          export CODE_DIR=$3
          export CODE_URL=http://10.10.11.10:$PORT/?folder=$CODE_DIR

          if [[ "$4" == "waypipe" ]]; then
            rm /tmp/waypipe.sock || true
            ${pkgs.socat}/bin/socat TCP-LISTEN:12345,reuseaddr,fork UNIX-CONNECT:/tmp/waypipe.sock
            ${pkgs.waypipe}/bin/waypipe -s /tmp/waypipe.sock client &
          fi

          chromium \
                  --app=$CODE_URL \
                  --unsafely-treat-insecure-origin-as-secure=$CODE_URL \
                  --disable-features=IsolateOrigins,site-per-process \
                  --user-data-dir="$(mktemp -d)"
          ;;
        lcode)
          export PORT="''${PORT:-$((RANDOM % 801 + 8100))}" # Random port between 8100 and 8900 if PORT isn't set
          f scode &
          f ocode $PORT $PWD
          ;;
        *)
          echo "Usage: $0 {rb|secret|scode|ocode|lcode}"
          exit 1
          ;;
      esac
    '';

    # build-system = pkgs.writeShellScriptBin "build-system" ''
    # '';
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

        f-util
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
