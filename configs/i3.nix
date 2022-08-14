{
  system = { pkgs, ... }: {
    services.xserver = {
      enable = true;
    #   # displayManager = {
    #   #     defaultSession = "none+i3";
    #   # };

      windowManager.i3 = {
        enable = true;
      	package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          dmenu
        ];
      };
    };
  };

  home = { pkgs, lib, ... }: with lib; {
    home.packages = with pkgs; [
      feh
      imagemagick
    ];

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraConfig = ''
        for_window [class="^.*"] border pixel 0
      '';
      
      # window.border = 0;

      config = rec {
        modifier = "Mod1";

        # modes = {
        #   resize = {
        #     "h" = "resize shrink width 10 px or 10 ppt";
        #     "j" = "resize grow height 10 px or 10 ppt";
        #     "k" = "resize shrink height 10 px or 10 ppt";
        #     "l" = "resize grow width 10 px or 10 ppt";
        #     "Escape" = ''mode "default"'';
        #     "${modifier}+r" = ''mode "default"'';
        #   };
        # };

        fonts = {
          names = [ "DejaVuSansMono" "Terminus" ];
          style = "Bold Semi-Condensed";
          size = 13.5;
        };

        gaps = let
          houter = 16;
          vouter = 16;
        in {
          left = 25+houter; # for eww
      	  # smartGaps = true;
          inner = 16;
          # outer = 16;
          horizontal = houter - 16;
          vertical = vouter - 16;
        };

        bars = [ ];
       
        startup = [
          {
            command = "${pkgs.feh}/bin/feh --bg-scale ${../assets/background.png}";
            always = true;
            notification = false;
          }
	];
	
        keybindings = mkMerge [{
            # "${modifier}+r" = ''mode "resize"'';
            
            "${modifier}+Shift+r" = "restart";
            "${modifier}+q" = "kill";
            "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
            "${modifier}+Shift+x" = "exec systemctl suspend";
            "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
            "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";

            # Focus
            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            # Move
            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";
            
            # Resize
            "${modifier}+y" = "resize shrink width 10 px or 10 ppt";
            "${modifier}+u" = "resize grow height 10 px or 10 ppt";
            "${modifier}+i" = "resize shrink height 10 px or 10 ppt";
            "${modifier}+o" = "resize grow width 10 px or 10 ppt";

            "--release Print" = "exec ${pkgs.imagemagick}/bin/import ~/screenshot.png";
          }
          (mkMerge (map (num: let strNum = builtins.toString num; in {
            "${modifier}+${strNum}" = "workspace ${strNum}";
            "${modifier}+Shift+${strNum}" = "move container to workspace ${strNum}";
          }) [1 2 3 4 5 6 7 8 9]))
        ];
        
        colors = {
          background = "#586e75";
          # statusline = "#ffffff";

          # focused = {
          #   workspace = "#55ffff #002b36";
          # };

          # focusedInactive = {
          #   workspace = "#ffffff #333333";
          # };

          # unfocused = {
          #   workspace = "#888888 #222222";
          # };

          # urgent = {
          #   workspace = "#ffffff #900000";
          # };
        };
      };
    };
  };
}
