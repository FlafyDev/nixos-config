pkgs: {
  type = "lua";
  plugin = pkgs.vimPlugins.which-key-nvim;
  config = builtins.readFile ./config.lua;
}