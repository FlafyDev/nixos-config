pkgs: with pkgs.vimPlugins; [
  cmp-nvim-lsp
  flutter-tools-nvim
  {
    type = "lua";
    plugin = nvim-lspconfig;
    config = builtins.readFile ./config.lua;
  }
]
