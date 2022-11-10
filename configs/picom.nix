{
  home = _: {
    services.picom = {
      enable = true;
      # shadow = true;
      # shadowOffsets = [ (-10) (-15) ];
      # shadowOpacity = 0.8;

      activeOpacity = 1.0;
      inactiveOpacity = 1.0;

      # fade = true;
      # fadeDelta = 1;
      # fadeSteps = [ 0.01 0.01 ];
      # fadeExclude = [
      #   "class_g != 'Rofi'"
      # ];

      backend = "glx";
      vSync = true;
      experimentalBackends = true;
      settings = {
        # "unredir-if-possible" = true;
        # "dbe" = true;
        # inactive-dim = 0.4;
        transparent-clipping = true;
        blur = {
          method = "dual_kawase";
          strength = 15;
          deviation = 14;
          kernel = "11x11gaussian";
          background = true;
          background-frame = true;
          background-fixed = true;
          kern = "3x3box";
        };

        blur-background-exclude = [
          "class_g = 'firefox'"
          "role   = 'xborder'"
          "class_g = 'eww-bar'"
        ];

        round-borders = 0;
        corner-radius = 0;
        rounded-corners-exclude = [
          "class_g = 'eww-bar'"
          "class_g = 'Rofi'"
        ];
        # WARN: Unofficial animation support (pijulius)
        # animations = true;
        # # `auto`, `none`, `fly-in`, `zoom`, `slide-down`, `slide-up`, `slide-left`, `slide-right` `slide-in`, `slide-out`
        # animation-for-transient-window = "zoom";
        # animation-for-open-window = "zoom";
        # animation-for-unmap-window = "zoom";
        # # animation-stiffness = 350;
        # animation-dampening = 20;
        # # animation-window-mass = 0.5;
        # # animation-delta = 8;
        # animation-clamping = false;
        # # animation-for-workspace-switch-in = "slide-down";
        # # animation-for-workspace-switch-out = "slide-up";

        # WARN: Unofficial animation support (dccsillag)
        # animations = true;
        # animation-stiffness = 201;
        # animation-window-mass = 0.4;
        # animation-dampening = 20;
        # animation-clamping = false;
        # animation-for-open-window = "slide-up"; #open window
      };
      opacityRules = [
        # "85:class_g = 'Code'"
        # "88:class_g = 'discord'"
        "100:class_g = 'firefox'"
        # "100:class_g = 'Alacritty'"
      ];
      # package = pkgs.picom.overrideAttrs(o: {
      #   # src = pkgs.fetchFromGitHub {
      #   #   owner = "dccsillag";
      #   #   repo = "picom";
      #   #   rev = "implement-window-animations";
      #   #   sha256 = "sha256-crCwRJd859DCIC0pEerpDqdX2j8ZrNAzVaSSB3mTPN8=";
      #   # };
      #   # src = pkgs.fetchFromGitHub {
      #   #   repo = "picom";
      #   #   owner = "ibhagwan";
      #   #   rev = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";
      #   #   sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
      #   # };
      #   # src = pkgs.fetchFromGitHub {
      #   #   repo = "picom";
      #   #   owner = "pijulius";
      #   #   rev = "982bb43e5d4116f1a37a0bde01c9bda0b88705b9";
      #   #   sha256 = "YiuLScDV9UfgI1MiYRtjgRkJ0VuA1TExATA2nJSJMhM=";
      #   # };
      # });
    };
  };
}
