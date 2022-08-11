pkgs: {
  type = "lua";
  plugin = pkgs.vimPlugins.nvim-tree-lua;
  config = builtins.readFile ./config.lua;
}