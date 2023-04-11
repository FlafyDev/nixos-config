pkgs:
with pkgs.vimPlugins; [
  cmp-nvim-lsp
  flutter-tools-nvim
  null-ls-nvim
  nvim-code-action-menu
  luasnip
  nvim-cmp
  vim-vsnip
  {
    type = "lua";
    plugin = nvim-lspconfig;
    config = builtins.readFile ./config.lua;
  }
]
