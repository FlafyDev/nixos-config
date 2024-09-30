{inputs, ...}: {
  inputs = {
    bufresize-nvim = {
      url = "github:kwkarlwang/bufresize.nvim";
      flake = false;
    };
    flutter-tools-nvim = {
      url = "github:akinsho/flutter-tools.nvim";
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
    tailwind-tools = {
      url = "github:luckasRanarison/tailwind-tools.nvim";
      flake = false;
    };
  };
  os.nixpkgs.overlays = [
    (_final: prev: {
      vimPlugins =
        prev.vimPlugins
        // (
          let
            inherit (prev.vimUtils) buildVimPlugin;
          in
            with inputs; {
              lspsaga-nvim = buildVimPlugin {
                pname = "lspsaga.nvim";
                version = "git";
                src = lspsaga-nvim;
              };
              bufresize-nvim = buildVimPlugin {
                pname = "bufresize.nvim";
                version = "git";
                src = bufresize-nvim;
              };
              tailwind-tools-nvim = buildVimPlugin {
                pname = "tailwind-tools.nvim";
                version = "git";
                src = tailwind-tools;
              };
              flutter-tools-nvim = buildVimPlugin {
                pname = "flutter-tools.nvim";
                version = "git";
                src = flutter-tools-nvim;
                # patches = [
                #   ./flutter-tools-no-resolve.patch
                # ];
              };
              transparent-nvim = buildVimPlugin {
                pname = "transparent-nvim";
                version = "git";
                src = transparent-nvim;
              };

            }
        );
    })
  ];
}
