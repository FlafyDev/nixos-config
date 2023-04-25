{neovide ? true}: {
  configs = cfgs:
    with cfgs; [
      nur
    ];

  inputs = {
    neovide = {
      url = "github:Yesterday17/neovide/new-keyboard-v3";
      # url = "path:/mnt/general/repos/flafydev/neovide";
      flake = false;
    };
    custom-theme-nvim = {
      url = "github:Djancyp/custom-theme.nvim";
      flake = false;
    };
    yuck-vim = {
      url = "github:elkowar/yuck.vim";
      flake = false;
    };
    bufresize-nvim = {
      url = "github:kwkarlwang/bufresize.nvim";
      flake = false;
    };
    flutter-tools-nvim = {
      url = "github:flafydev/flutter-tools.nvim";
      flake = false;
    };
    centerpad-nvim = {
      url = "github:smithbm2316/centerpad.nvim";
      flake = false;
    };
    lspsaga-nvim = {
      url = "github:glepnir/lspsaga.nvim";
      flake = false;
    };
    transparent-nvim = {
      url = "github:xiyaowong/transparent.nvim";
      flake = false;
    };
    flutter-riverpod-snippets = {
      url = "github:RobertBrunhage/flutter-riverpod-snippets";
      flake = false;
    };
    flutter-hooks-snippets = {
      url = "github:devmuaz/flutter-hooks-snippets";
      flake = false;
    };
    lspsaga = {
      url = "github:nvimdev/lspsaga.nvim";
      flake = false;
    };
  };

  add = inputs: {
    overlays = _: [
      (_final: prev: {
        # neovide = prev.callPackage ./neovide {
        #   src = inputs.neovide;
        # };
        # neovide = prev.neovide.overrideAttrs (old: {
        #   src = inputs.neovide;
        #
        #   # nativeBuildInputs = old.nativeBuildInputs ++ [prev.cmake];
        #   cargoDeps = old.cargoDeps.overrideAttrs (_: {
        #     src = inputs.neovide;
        #     outputHash = prev.lib.fakeHash;
        #   });
        # });
        vimPlugins =
          prev.vimPlugins
          // (
            let
              inherit (prev.vimUtils) buildVimPluginFrom2Nix;
            in {
              lspsaga-nvim = buildVimPluginFrom2Nix {
                pname = "lspsaga.nvim";
                version = "git";
                src = inputs.lspsaga-nvim;
              };
              custom-theme-nvim = buildVimPluginFrom2Nix {
                pname = "custom-theme.nvim";
                version = "git";
                src = inputs.custom-theme-nvim;
              };
              bufresize-nvim = buildVimPluginFrom2Nix {
                pname = "bufresize.nvim";
                version = "git";
                src = inputs.bufresize-nvim;
              };
              flutter-tools-nvim = buildVimPluginFrom2Nix {
                pname = "flutter-tools.nvim";
                version = "git";
                src = inputs.flutter-tools-nvim;
              };
              yuck-vim = buildVimPluginFrom2Nix {
                pname = "yuck-vim";
                version = "git";
                src = inputs.yuck-vim;
              };
              centerpad-nvim = buildVimPluginFrom2Nix {
                pname = "centerpad-nvim";
                version = "git";
                src = inputs.centerpad-nvim;
              };
              transparent-nvim = buildVimPluginFrom2Nix {
                pname = "transparent-nvim";
                version = "git";
                src = inputs.transparent-nvim;
              };
            }
          );
      })
    ];
  };

  home = {
    pkgs,
    theme,
    ...
  }: {
    home.packages =
      if neovide
      then [
        pkgs.neovide
        (pkgs.writeShellScriptBin "vim" ''env -u WAYLAND_DISPLAY nvidia-offload ${pkgs.neovide}/bin/neovide --nofork "$@"'')
      ]
      else [];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    imports = [
      ./plugins
    ];

    programs.neovim = {
      enable = true;

      extraConfig = ''
        lua<<EOF
        ${builtins.readFile (
          pkgs.substituteAll {
            src = ./init.lua;
            inherit (theme.colors) activeBorder;
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
    };
  };
}
