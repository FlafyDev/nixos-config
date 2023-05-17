{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.direnv;
in {
  options.programs.direnv = {
    enable = mkEnableOption "direnv";
  };

  config = mkIf cfg.enable {
    home.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home.xdg.configFile."direnv/direnvrc".text = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          local hash="$(sha1sum - <<<"''${PWD}" | cut -c-7)"
          local path="''${PWD//[^a-zA-Z0-9]/-}"
          echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
        )}"
      }
    '';
  };
}
