{
  inputs = {
    neovim-flake = {
      url = "github:NotAShelf/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {neovim-flake, ...}: {
    homeModules = [neovim-flake.homeManagerModules.default];
  };

  home = _: {
    programs.neovim-flake = {
      enable = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;
          wordWrap = false;
          debugMode = {
            enable = false;
            level = 20;
            logFile = "/tmp/nvim.log";
          };
        };

        vim.lsp = {
          enable = true;
          formatOnSave = true;
          lightbulb.enable = false;
          dart.flutter-tools = {
            enable = true;
            color = {
              highlightBackground = false;
              highlightForeground = false;
              virtualText = {
                enable = true;
              };
            };
          };
          lspsaga.enable = false;
          nvimCodeActionMenu.enable = true;
          trouble.enable = false;
          lspSignature.enable = true;
          rust.enable = true;
          python = true;
          clang.enable = true;
          sql = true;
          ts = true;
          nix = {
            enable = true;
            formatter = "alejandra";
          };
        };

        vim.visuals = {
          enable = true;
          nvimWebDevicons.enable = true;
          scrollBar.enable = false;
          smoothScroll.enable = false;
          cellularAutomaton.enable = false;
          fidget-nvim.enable = true;
          lspkind.enable = false; # Maybe enable
          indentBlankline = {
            enable = false;
            fillChar = "";
            eolChar = "";
            showCurrContext = true;
          };
          cursorWordline = {
            enable = false;
            lineTimeout = 0;
          };
        };

        vim.statusline = {
          lualine = {
            enable = true;
            theme = "catppuccin";
          };
        };

        vim.theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
        };
        vim.autopairs.enable = true;

        vim.autocomplete = {
          enable = true;
          type = "nvim-cmp";
        };

        vim.filetree = {
          nvimTreeLua = {
            enable = true;
            view = {
              width = 25;
            };
          };
        };

        vim.tabline = {
          nvimBufferline.enable = false;
        };

        vim.treesitter = {
          enable = true;
          context.enable = true;
        };

        vim.binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        vim.telescope = {
          enable = true;
        };

        vim.markdown = {
          enable = true;
          glow.enable = true;
        };

        vim.git = {
          enable = true;
          gitsigns.enable = true;
        };

        vim.minimap = {
          minimap-vim.enable = false;
          codewindow.enable = false; # lighter, faster, and uses lua for configuration
        };

        vim.dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = false;
        };

        vim.notify = {
          nvim-notify.enable = true;
        };

        vim.utility = {
          colorizer.enable = true;
          icon-picker.enable = true;
          venn-nvim.enable = false; # FIXME throws an error when its commands are ran manually
          diffview-nvim.enable = true;
        };

        vim.notes = {
          obsidian.enable = false; # FIXME neovim fails to build if obsidian is enabled
          orgmode.enable = false;
          mind-nvim.enable = false;
          todo-comments.enable = true;
        };

        vim.terminal = {
          toggleterm.enable = false;
        };

        vim.ui = {
          noice.enable = false;
        };

        vim.assistant = {
          copilot.enable = true;
          #tabnine.enable = false; # FIXME: this is not working because the plugin depends on an internal script to be ran by the package manager
        };

        vim.session = {
          nvim-session-manager.enable = false;
        };

        vim.gestures = {
          gesture-nvim.enable = false;
        };

        vim.comments = {
          comment-nvim.enable = true;
          kommentary.enable = false;
        };

        vim.presence = {
          presence-nvim = {
            enable = true;
            auto_update = true;
            image_text = "The One True Text Editor";
            client_id = "793271441293967371";
            main_image = "neovim";
            rich_presence = {
              editing_text = "Editing %s";
            };
          };
        };
      };
    };
  };
}
