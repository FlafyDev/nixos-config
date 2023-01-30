{
  add = _: {
    overlays = _: [
      (final: prev: {
        helix = prev.helix.overrideAttrs (old: rec {
          # src = prev.fetchFromGitHub {
          #   owner = "helix-editor";
          #   repo = "helix";
          #   rev = "f4c8647a7deca64d9060f99689ec79fc6090d2e7";
          #   sha256 = "sha256-2ri/h34Uyto7gArbkELVO8BLHsYjUV4ecCefovWXjVY=";
          # };
          # cargoDeps = old.cargoDeps.overrideAttrs (_: {
          #   inherit src; # You need to pass "src" here again,
          #   # otherwise the old "src" will be used.
          #   outputHash = "sha256-6AXJiU5g6y+h2dFNG9qABwVeBgMjr6AxXekMTsr9O3k=";
          # });
          # patches =
          #   (old.patches or [])
          #   ++ [
          #     ./patches/global-search.diff
          #   ];
        });
      })
    ];
  };

  home = {pkgs, ...}: {
    programs.helix = {
      enable = true;
      settings = {
        keys = {
          normal = {
            C-s = ":w";
          };
        };

        editor = {
          line-number = "relative";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
        };
      };
    };
  };
}
