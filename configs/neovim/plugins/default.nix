{ pkgs, lib, config, ... }: {
  programs.neovim.plugins = (lib.lists.flatten (map (plugin: (import plugin) pkgs) [
    ./telescope-nvim
    ./lualine-nvim
    ./lspconfig
    ./cmp
  ])) ++ (with pkgs.vimPlugins; let
    inherit (pkgs.nur.repos.m15a) vimExtraPlugins; 
  in [
    vim-nix
    nvim-web-devicons
    nvim-base16  
    markdown-preview-nvim
    vim-visual-multi
    vim-parinfer
    # vim-hexokinase
    vim-wayland-clipboard
    yuck-vim
    vim-surround
    tokyonight-nvim
    vimExtraPlugins.nvim-transparent
    flutter-tools-nvim
    {
      type = "lua";
      plugin = nvim-treesitter;
      config = ''
        require('nvim-treesitter.configs').setup {
          sync_install = false,
          auto_install = true,

          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        }      
      '';
    }
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
    # {
    #   type = "lua";
    #   plugin = Shade-nvim;
    #   config = ''
    #     require'shade'.setup({
    #       overlay_opacity = 50,
    #       opacity_step = 1,
    #     })
    #   '';
    # }
    {
      plugin = nvim-autopairs;
      config = "lua require('nvim-autopairs').setup {}";
    }
    {
      plugin = range-highlight-nvim;
      config = "lua require('range-highlight').setup {}";
    }
    {
      plugin = twilight-nvim;
      config = "lua require('twilight').setup {}";
    }
    # flutter-tools-nvim
    # copilot-vim
  ]);
}

