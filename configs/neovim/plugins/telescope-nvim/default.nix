pkgs: {
  type = "lua";
  plugin = pkgs.vimPlugins.telescope-nvim;
  config = builtins.readFile ./config.lua;
}