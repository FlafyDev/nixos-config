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
      type = "lua";
      plugin = null-ls-nvim;
      config = ''
        local nb = require('null-ls').builtins

        require('null-ls').setup({
            sources = {
                nb.formatting.alejandra,
                nb.code_actions.statix,
                nb.diagnostics.cppcheck,
                nb.diagnostics.deadnix,
                nb.diagnostics.statix,
                nb.diagnostics.eslint,
                nb.completion.spell,
            },
        })
      '';
    }
    {
      plugin = custom-theme-nvim;
      config = "lua require('custom-theme').setup()";
    }
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
          parser_install_dir = "~/.cache/treesitter",
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
          renderer = {
            full_name = true,
            highlight_opened_files = "all",
          };
          diagnostics = {
            enable = true,
            show_on_dirs = false,
            debounce_delay = 50,
            icons = {
              hint = "",
              info = "",
              warning = "",
              error = "",
            },
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

