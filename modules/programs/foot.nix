{
  lib,
  config,
  theme,
  ...
}: let
  cfg = config.programs.foot;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.foot = {
    enable = mkEnableOption "foot";
  };

  config = mkIf cfg.enable {
    hm.programs.foot = {
      enable = true;
      settings = {
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
          background = theme.backgroundColor.toHexRGB;
          alpha = theme.backgroundColor.toNormA;
          # alpha = 0.0;

          foreground = "c0caf5";
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
