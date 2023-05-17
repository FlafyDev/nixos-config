{
  home = {
    lib,
    theme,
    ...
  }: {
    programs.foot = {
      enable = true;
      settings = let
        # TODO: Move this from here.
        hexToDec = v: let
          hexToInt = {
            "0" = 0;
            "1" = 1;
            "2" = 2;
            "3" = 3;
            "4" = 4;
            "5" = 5;
            "6" = 6;
            "7" = 7;
            "8" = 8;
            "9" = 9;
            "a" = 10;
            "b" = 11;
            "c" = 12;
            "d" = 13;
            "e" = 14;
            "f" = 15;
          };
          chars = lib.stringToCharacters v;
          charsLen = lib.length chars;
        in
          lib.foldl
          (a: v: a + v)
          0
          (lib.imap0
            (k: v: hexToInt."${v}" * (lib.pow 16 (charsLen - k - 1)))
            chars);
      in {
        main = {
          term = "foot";
          # font = "monospace:size=11";
          font = "FiraCode Nerd Font Mono:size=11";
          dpi-aware = "no";
          pad = "10x10";
        };

        mouse = {
          hide-when-typing = "yes";
        };

        cursor.color = "c0caf5 ffffff";

        colors = {
          # alpha = hexToDec theme.colors.blurredBackgroundColor.opacity;
          alpha = 0.0;

          foreground = "c0caf5";
          background = theme.colors.blurredBackgroundColor.col;
          selection-foreground = "c0caf5";
          selection-background = "33467c";
          urls = "73daca";

          regular0 = "15161e";
          regular1 = "f7768e";
          regular2 = "9ece6a";
          regular3 = "e0af68";
          regular4 = "7aa2f7";
          regular5 = "bb9af7";
          regular6 = "7dcfff";
          regular7 = "a9b1d6";

          bright0 = "414868";
          bright1 = "f7768e";
          bright2 = "9ece6a";
          bright3 = "e0af68";
          bright4 = "7aa2f7";
          bright5 = "bb9af7";
          bright6 = "7dcfff";
          bright7 = "c0caf5";

          "16" = "ff9e64";
          "17" = "db4b4b";

          # background="1a1b26";
          # foreground="c0caf5";
          # regular0="15161E";
          # regular1="f7768e";
          # regular2="9ece6a";
          # regular3="e0af68";
          # regular4="7aa2f7";
          # regular5="bb9af7";
          # regular6="7dcfff";
          # regular7="a9b1d6";
          # bright0="414868";
          # bright1="f7768e";
          # bright2="9ece6a";
          # bright3="e0af68";
          # bright4="7aa2f7";
          # bright5="bb9af7";
          # bright6="7dcfff";
          # bright7="c0caf5";
          # foreground = "${base05}"; # Text
          # background = "${base00}"; # Base
          # regular0 = "${base00}";
          # regular1 = "${base08}";
          # regular2 = "${base0B}";
          # regular3 = "${base0A}";
          # regular4 = "${base0D}";
          # regular5 = "${base0E}";
          # regular6 = "${base0C}";
          # regular7 = "${base05}";
          # bright0 = "${base03}";
          # bright1 = "${base08}";
          # bright2 = "${base0B}";
          # bright3 = "${base0A}";
          # bright4 = "${base0D}";
          # bright5 = "${base0E}";
          # bright6 = "${base0C}";
          # bright7 = "${base07}";
        };
      };
    };
  };
}
