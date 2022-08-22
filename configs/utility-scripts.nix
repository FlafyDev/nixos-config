{
  system = { pkgs, ... }: {
    environment.systemPackages = let 
      nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '';
      updateSystem = pkgs.writeShellScriptBin "updateSystem" ''
        case $2 in
          fast)
            nixos-rebuild test --fast --flake ./#$1
            ;;
          *)
            nixos-rebuild switch --flake ./#$1
            ;;
        esac
      '';
    in [
      nvidia-offload
      updateSystem
    ];
  };
}
