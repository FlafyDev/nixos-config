{
  home = { pkgs, ... }: {
    programs.neovim = {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        telescope-nvim
        nvim-tree-lua
        # flutter-tools-nvim
        # nvim-web-devicons
        # copilot-vim
        # nvim-treesitter
        # nvim-autopairs
        # luasnip
        # which-key-nvim
      ];
    };
  };
  
}