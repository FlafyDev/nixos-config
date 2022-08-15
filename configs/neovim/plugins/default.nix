pkgs: (map (plugin: (import plugin) pkgs) [
  ./telescope-nvim
  ./lualine-nvim
]) ++ (with pkgs.vimPlugins; [
  vim-nix
  nvim-web-devicons
  nvim-treesitter
  nvim-base16  
  {
    plugin = nvim-tree-lua;
    config = "lua require('nvim-tree').setup()";
  } 
  {
    plugin = sniprun;
    config = "lua require('sniprun').setup()";
  } 
  {
    plugin = which-key-nvim;
    config = "lua require('which-key').setup({})";
  } 


  # flutter-tools-nvim
  # copilot-vim
  # nvim-autopairs
  # luasnip
])
