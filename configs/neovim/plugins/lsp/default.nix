{snippets ? []}: pkgs:
with pkgs.vimPlugins; let
  preprocessSnippetsPath = snippetsSrc:
    pkgs.stdenvNoCC.mkDerivation {
      name = "preprocessed-nvim-snippets";
      src = snippetsSrc;
      buildPhase = ''
        # Change all filenames that end with .code-snippets to .json
        find . -name "*.code-snippets" -type f -exec sh -c 'mv "$0" "''${0%.code-snippets}.json"' {} \;

        # Modify all files that contain .code-snippets to .json
        find . -type f -exec sed -i 's/.code-snippets/.json/g' {} +
      '';
      installPhase = ''
        mkdir -p $out
        cp -r . $out
      '';
    };
in [
  flutter-tools-nvim
  null-ls-nvim
  nvim-code-action-menu
  # coq_nvim
  # coq-thirdparty
  # coq-artifacts
  # vim-vsnip
  luasnip
  cmp_luasnip
  nvim-cmp
  cmp-nvim-lsp
  {
    type = "lua";
    plugin = nvim-lspconfig;
    config = builtins.readFile (pkgs.substituteAll {
      src = ./config.lua;
      snippets = pkgs.lib.concatStringsSep "," (map preprocessSnippetsPath snippets);
    });
  }
]
