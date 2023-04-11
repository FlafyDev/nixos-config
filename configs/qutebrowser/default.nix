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
      searchEngines = {
        "DEFAULT" = "https://google.com/search?hl=en&q={}";
        "!a" = "https://www.amazon.com/s?k={}";
        "!d" = "https://duckduckgo.com/?ia=web&q={}";
        "!dd" = "https://thefreedictionary.com/{}";
        "!e" = "https://www.ebay.com/sch/i.html?_nkw={}";
        "!fb" = "https://www.facebook.com/s.php?q={}";
        "!gh" = "https://github.com/search?o=desc&q={}&s=stars";
        "!gist" = "https://gist.github.com/search?q={}";
        "!gi" = "https://www.google.com/search?tbm=isch&q={}&tbs=imgo:1";
        "!gn" = "https://news.google.com/search?q={}";
        "!ig" = "https://www.instagram.com/explore/tags/{}";
        "!m" = "https://www.google.com/maps/search/{}";
        "!p" = "https://pry.sh/{}";
        "!r" = "https://www.reddit.com/search?q={}";
        "!sd" = "https://slickdeals.net/newsearch.php?q={}&searcharea=deals&searchin=first";
        "!t" = "https://www.thesaurus.com/browse/{}";
        "!tw" = "https://twitter.com/search?q={}";
        "!w" = "https://en.wikipedia.org/wiki/{}";
        "!yelp" = "https://www.yelp.com/search?find_desc={}";
        "!yt" = "https://www.youtube.com/results?search_query={}";
      };
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
