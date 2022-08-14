pkgs: (map (plugin: (import plugin) pkgs) [
  ./nvim-tree-lua
  ./telescope-nvim
  ./which-key-nvim
  ./sniprun
]) ++ (with pkgs.vimPlugins; [
  nvim-web-devicons
  
  # nvim-tree-lua
  # flutter-tools-nvim
  # nvim-web-devicons
  # copilot-vim
  nvim-treesitter
  # nvim-autopairs
  # luasnip
  # which-key-nvim
])
