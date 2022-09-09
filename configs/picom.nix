{
  home = { pkgs, ... }: {
    services.picom = {
      enable = true;
      # shadow = true;
      # shadowOffsets = [ (-10) (-15) ];
      # shadowOpacity = 0.8;

      activeOpacity = 1.0;
      inactiveOpacity = 1.0; 

      fade = true;
      fadeDelta = 1;
      fadeSteps = [ 0.01 0.01 ];
      fadeExclude = [
        "class_g != 'Rofi'"
      ];

      backend = "glx";
      vSync = true;
      settings = {
        # "unredir-if-possible" = true;
        # "dbe" = true;
        inactive-dim = 0.2;
        blur = {
          method = "dual_kawase";
          size = 20;
          background = false;
          background-frame = false;
          background-fixed = false;
        };

        blur-background-exclude = [
          "class_g = 'firefox'"
          "role   = 'xborder'"
          "class_g = 'eww-bar'"
        ];
        
        round-borders = 0;
        corner-radius = 10;
        rounded-corners-exclude = [
          "class_g = 'eww-bar'"
          "class_g = 'Rofi'"
        ];

        # WARN: Unofficial animation support (dccsillag)
        # animations = true;
        # animation-stiffness = 201;
        # animation-window-mass = 0.4;
        # animation-dampening = 20;
        # animation-clamping = false;
        # animation-for-open-window = "zoom"; #open window
        # animation-for-unmap-window = "zoom"; #minimize window
        # animation-for-workspace-switch-in = "slide-down"; #the windows in the workspace that is coming in
        # animation-for-workspace-switch-out = "zoom"; #the windows in the workspace that are coming out
        # animation-for-transient-window = "none"; #popup windows
      };
      opacityRules = [
        # "85:class_g = 'Code'"
        # "88:class_g = 'discord'"
        "100:class_g = 'firefox'"
        # "100:class_g = 'Alacritty'"
      ];
      package = pkgs.picom.overrideAttrs(o: {
        # src = pkgs.fetchFromGitHub {
        #   owner = "dccsillag";
        #   repo = "picom";
        #   rev = "implement-window-animations";
        #   sha256 = "sha256-crCwRJd859DCIC0pEerpDqdX2j8ZrNAzVaSSB3mTPN8=";
        # };
        src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "ibhagwan";
          rev = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";
          sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
        };
      });
    };
  };
}
