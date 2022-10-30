{
  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      ripgrep
      fd
    ];

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
        nodePackages.pyright
        clang
        nodejs-18_x
        tree-sitter
        rnix-lsp
        clang-tools
        ccls
        wl-clipboard
        omnisharp-roslyn
        netcoredbg
        gcc # treesitter
        nixfmt
        nodePackages.typescript-language-server
        python310Packages.autopep8
      ];
    };
  };
  
}
