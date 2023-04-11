{
  pkgs,
  lib,
  ...
}: {
  programs.neovim.plugins =
    (lib.lists.flatten (map (plugin: (import plugin) pkgs) [
      ./telescope-nvim
      ./lualine-nvim
      ./lsp
      ./nvim-dap
    ]))
    ++ (with pkgs.vimPlugins; let
      inherit (pkgs.nur.repos.m15a) vimExtraPlugins;
    in [
      vim-nix
      nvim-web-devicons
      markdown-preview-nvim
      vim-visual-multi
      vim-parinfer
      tokyonight-nvim
      vim-wayland-clipboard
      yuck-vim
      vim-surround
      rust-tools-nvim
      copilot-vim
      centerpad-nvim
      {
        type = "lua";
        plugin = fidget-nvim;
        config = ''
          require('fidget').setup({
            window = {
              relative = "win", -- where to anchor, either "win" or "editor"
              blend = 0, -- &winblend for the window
              zindex = nil, -- the zindex value for the window
              border = "none", -- style of border for the fidget window
            },
          })
        '';
      }

      {
        plugin = barbecue-nvim;
        config = "lua require('barbecue').setup({theme = 'tokyonight', show_modified = true,})";
      }
      {
        type = "lua";
        plugin = indent-blankline-nvim;
        config = ''
          vim.opt.list = true
          -- vim.opt.listchars:append "eol:↴"

          require("indent_blankline").setup {
            -- show_end_of_line = true,
            -- show_current_context = true,
          }
        '';
      }
      {
        plugin = gitsigns-nvim;
        config = "lua require('gitsigns').setup()";
      }
      {
        plugin = custom-theme-nvim;
        config = "lua require('custom-theme').setup()";
      }
      {
        plugin = comment-nvim;
        config = "lua require('Comment').setup()";
      }
      {
        plugin = bufresize-nvim;
        config = ''lua require('bufresize').setup()'';
      }
      {
        type = "lua";
        plugin = transparent-nvim;
        config = ''
          require("transparent").setup({
            extra_groups = {
              "VertSplit",
              "StatusLine",
              "StatusLineNC",
              # "SignColumn",
              "NvimTreeNormal",
              "NvimTreeNormalNC",
              "TelescopeNormal",
              "TelescopeBorder",
              "NvimTreeWinSeparator",
              "LspInfoBorder",
              "LspReferenceRead",
              "LspReferenceText",
              "LspFloatWinNormal",
              "LspReferenceWrite",
              "LspSignatureAciveParameter",
              "NormalFloat",
              "WhichKeyFloat",
              "FloatShadow",
              "FloatShadowThrough",
              "FloatBorder",
              "FidgetTitle",
              "FidgetTask",
              "lualine_c_normal",
            },
          })
        '';
      }
      {
        type = "lua";
        plugin = nvim-treesitter.withPlugins (
          _:
            lib.filter (
              g:
              # Crashes neovim. Blacklist for now.
                g.pname != "nix-grammar"
            )
            nvim-treesitter.allGrammars
        );
        config = ''
          require('nvim-treesitter.configs').setup {
            indent = { enable = true },
            highlight = { enable = true },
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
              -- highlight_opened_files = "all",
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
        plugin = which-key-nvim;
        config = "lua require('which-key').setup({})";
      }
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
    ]);
}
