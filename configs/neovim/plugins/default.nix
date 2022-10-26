{ pkgs, lib, config, ... }: {
  programs.neovim.plugins = (lib.lists.flatten (map (plugin: (import plugin) pkgs) [
    ./telescope-nvim
    ./lualine-nvim
    ./lspconfig
    ./cmp
    ./nvim-dap
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
    {
      plugin = nvim-comment;
      config = "lua require('nvim_comment').setup()";
    }
    {
      type = "lua";
      plugin = neoformat;
      config = ''
        -- vim.api.nvim_create_autocmd("BufWritePre", {
        --   command = [[silent! undojoin | Neoformat]],
        --   desc = "Format using neoformat on save.",
        --   group = vim.api.nvim_create_augroup("neoformat_format_onsave", { clear = true }),
        --   pattern = "*",
        -- })
      '';
    }
    {
      plugin = bufresize-nvim;
      config = ''lua require('bufresize').setup()'';
    }
    {
      type = "lua";
      plugin = vimExtraPlugins.nvim-transparent;
      config = ''
        require("transparent").setup({
          enable = true,
          extra_groups = {
            "LineNr",
            "VertSplit",
            "StatusLine",
            "StatusLineNC",
            # "SignColumn",
            "NvimTreeNormal",
            "NvimTreeNormalNC",
            "TelescopeNormal",
            "TelescopeBorder",
            "NvimTreeWinSeparator",
          },
        })
      '';
    }
    {
      type = "lua";
      plugin = nvim-treesitter;
      config = ''
        require('nvim-treesitter.configs').setup {
          sync_install = false,
          auto_install = true,
    
          disable = { "dart" },
    
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        }      
      '';
    }
    {
      type = "lua";
      plugin = nvim-tree-lua;
      config = ''
        require('nvim-tree').setup({
          view = {
            preserve_window_proportions = true,
          },
        })
      '';
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

