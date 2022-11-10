{
  inputs = {
    qutebrowser-base16 = {
      url = "github:base16-project/base16-qutebrowser";
      flake = false;
    };
  };

  add = {qutebrowser-base16, ...}: {
    overlays = _: [
      (_final: _prev: {
        inherit qutebrowser-base16;
      })
    ];
  };

  home = {pkgs, ...}: {
    programs.qutebrowser = {
      enable = true;
      settings = {
        colors.webpage.preferred_color_scheme = "dark";
        content.blocking.adblock.lists = [
          "https://easylist.to/easylist/easylist.txt"
          "https://easylist.to/easylist/easyprivacy.txt"
          "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
          "https://easylist.to/easylist/fanboy-annoyance.txt"
          "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
          "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt"
          "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt"
          "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt"
          "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt"
          "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt"
          "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt"
        ];

        content.blocking.enabled = true;
        content.blocking.hosts.lists = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
        content.blocking.method = "both";
        # fonts = {
        #   web.family = let
        #     serif = "Source Sans 3";
        #     # sans = "DejaVu Sans";
        #     # sans_mono = "DejaVu Sans Mono";
        #     sans = "Source Sans 3";
        #     sans_mono = "Source Sans 3";
        #   in {
        #     cursive = serif;
        #     fantasy = serif;
        #     fixed = sans_mono;
        #     sans_serif = sans;
        #     serif = serif;
        #     standard = sans;
        #   };
        # };
      };
      keyBindings = {
        normal = {
          "J" = "tab-prev";
          "K" = "tab-next";
        };
      };
      extraConfig = ''
        config.source('${pkgs.qutebrowser-base16}/themes/default/base16-blueish.config.py')
      '';
    };
  };
}
