{inputs, ...}: {
  inputs = {
    bufresize-nvim = {
      url = "github:kwkarlwang/bufresize.nvim";
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
