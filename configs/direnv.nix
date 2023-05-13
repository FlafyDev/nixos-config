{
  home = _: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    xdg.configFile."direnv/direnvrc".text = ''
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
