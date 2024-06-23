{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.programs.neovim;
  inherit (lib) mkEnableOption mkIf;
in {
  imports = [
    ./plugins.nix
  ];

  options.programs.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    hm.home.sessionVariables = {
      EDITOR = "nvim";
    };

    hm.programs.neovim = {
      enable = true;

      extraConfig = ''
        lua<<EOF
        ${builtins.readFile (
          pkgs.substituteAll {
            src = ./config/init.lua;
            activeBorder = "29A4BD";
            # activeBorder = config.theme.colors.activeBorder.col;
          }
        )}
        EOF
      '';

      extraPackages = with pkgs; [
        # msbuild
        dotnet-sdk
        omnisharp-roslyn
        sumneko-lua-language-server
        ripgrep
        # kotlin-language-server
        fd
        statix
        cppcheck
        deadnix
        alejandra
        nodePackages.pyright
        # nodejs-16_x
        tree-sitter
        nil
        clang-tools
        # cmake-language-server
        # ccls
        wl-clipboard
        # netcoredbg
        # gcc # treesitter
        nixfmt
        nodePackages.typescript-language-server
        python310Packages.autopep8
        lazygit
      ];

      plugins =
        (lib.lists.flatten (map (plugin:
          (
            if (lib.isFunction plugin)
            then plugin
            else (import plugin)
          )
          pkgs) [
          ./config/telescope-nvim
          ./config/lualine-nvim
          (import ./config/lsp {
            snippets = with inputs; [
              flutter-riverpod-snippets
              flutter-hooks-snippets
            ];
          })
          ./config/nvim-dap
        ]))
        ++ (with pkgs.vimPlugins; [
          # vim-nix # Nix's treesitter grammar is broken. Using this one instead.
          nvim-web-devicons
          markdown-preview-nvim
          vim-visual-multi
          vim-parinfer
          tokyonight-nvim
          vim-wayland-clipboard
          vim-surround
          rustaceanvim
          copilot-vim
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

          # {
          #   plugin = barbecue-nvim;
          #   config = "lua require('barbecue').setup({theme = 'tokyonight', show_modified = true,})";
          # }
          {
            type = "lua";
            plugin = indent-blankline-nvim;
            config = ''
              vim.opt.list = true
              -- vim.opt.listchars:append "eol:↴"

              require("ibl").setup {
                scope = {
                  show_start = false,
                  show_end = false,
                },
              }
              -- require("indent_blankline").setup {
                -- show_end_of_line = true,
                -- show_current_context = true,
              -- }
            '';
          }
          {
            plugin = gitsigns-nvim;
            config = "lua require('gitsigns').setup()";
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
            # plugin = nvim-treesitter.withPlugins (_: nvim-treesitter.allGrammars);
            plugin = nvim-treesitter.withPlugins (
              _:
                lib.filter (
                  # Slows neovim on indent. Blacklist for now.
                  g: g.pname != "dart-grammar"
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
    };
  };
}
