{
  configs = cfgs:
    with cfgs; [
      nur
    ];

  inputs = {
    neovide = {
      url = "github:williamspatrick/neovide";
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
      url = "github:akinsho/flutter-tools.nvim";
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
  };

  add = inputs: {
    overlays = _: [
      (_final: prev: {
        neovide = prev.neovide.overrideAttrs (old: {
          src = inputs.neovide;
          nativeBuildInputs = old.nativeBuildInputs ++ [ prev.cmake ];
          cargoDeps = old.cargoDeps.overrideAttrs (_: {
            src = inputs.neovide;
            outputHash = "sha256-wW/Z32X5YieTraEVbPKpj+59MzPjVKbgTaXyrZLwU50=";
          });
        });
        vimPlugins =
          prev.vimPlugins
          // (
            let
              inherit (prev.vimUtils) buildVimPluginFrom2Nix;
            in {
              lspsaga-nvim-original = prev.vimPlugins.lspsaga-nvim-original.overrideAttrs (_old: {
                src = inputs.lspsaga-nvim;
              });
              custom-theme-nvim = buildVimPluginFrom2Nix {
                pname = "custom-theme.nvim";
                version = "git";
                src = inputs.custom-theme-nvim;
              };
              bufresize-nvim = buildVimPluginFrom2Nix {
                pname = "bufresize.nvim";
                version = "2022-09-02";
                src = inputs.bufresize-nvim;
              };
              flutter-tools-nvim = buildVimPluginFrom2Nix {
                pname = "flutter-tools.nvim";
                version = "2022-08-26";
                src = inputs.flutter-tools-nvim;
                # src = fetchFromGitHub {
                #   owner = "FlafyDev";
                #   repo = "flutter-tools.nvim";
                #   rev = "1ea7eca2c88fd56bc64eaa71676b9290932ef2d4";
                #   sha256 = "d/rbkNLVe42dSdb68AizGbZb7mfPscp6V2NI6yEqLe8=";
                # };
                meta.homepage = "https://github.com/FlafyDev/flutter-tools.nvim/";
              };
              yuck-vim = buildVimPluginFrom2Nix {
                pname = "yuck-vim";
                version = "2022-06-20";
                src = inputs.yuck-vim;
                meta.homepage = "https://github.com/elkowar/yuck.vim";
              };
              centerpad-nvim = buildVimPluginFrom2Nix {
                name = "centerpad-nvim";
                src = inputs.centerpad-nvim;
                meta.homepage = "https://github.com/smithbm2316/centerpad.nvim";
              };
            }
          );
      })
    ];
  };

  home = {pkgs, ...}: {
    home.packages = with pkgs; [
      neovide
      (writeShellScriptBin "vim" "nvidia-offload ${pkgs.neovide}/bin/neovide --nofork $@")
    ];

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
          ${builtins.readFile ./init.lua}
        EOF
      '';

      extraPackages = with pkgs; [
        ripgrep
        kotlin-language-server
        fd
        statix
        cppcheck
        deadnix
        alejandra
        nodePackages.pyright
        nodejs-16_x
        tree-sitter
        # nil
        clang-tools
        cmake-language-server
        # ccls
        wl-clipboard
        omnisharp-roslyn
        netcoredbg
        gcc # treesitter
        nixfmt
        nodePackages.typescript-language-server
        python310Packages.autopep8
        lazygit
      ];
    };
  };
}
