pkgs: {
  type = "lua";
  plugin = pkgs.vimPlugins.nvim-dap;
  config = builtins.readFile ./config.lua;
}

