pkgs: with pkgs.vimPlugins; [
  cmp-nvim-lsp
  {
    type = "lua";
    plugin = nvim-lspconfig;
    config = builtins.readFile ./config.lua;
  }
]
