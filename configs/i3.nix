{
  system = { pkgs, ... }: {
    services.xserver = {
      enable = true;
    #   # displayManager = {
    #   #     defaultSession = "none+i3";
    #   # };
      dpi = 130;

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
      jq
      xborder
    ];

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraConfig = ''
        for_window [class="^.*"] border pixel 0
      '';
      
      # window.border = 0;

      config = rec {
        modifier = "Mod4";

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
          size = 19.5;
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
            command = "${pkgs.feh}/bin/feh --bg-scale ${../assets/background2.png}";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.i3-alternating-layout}/bin/i3-alternating-layout";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.eww}/bin/eww open bar";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.xborder}/bin/xborder --border-width 2 --border-rgba 11ee8e66";
            always = true;
            notification = false;
          }
          {
            command = (builtins.replaceStrings ["\n"] [" "] ''
              i3-msg -t subscribe -m '[ "window" ]' | while read -r arg; do
                if [ $(${pkgs.jq}/bin/jq '.container.fullscreen_mode' <<< $arg) == '1' ]; then
                  eww close bar;
                else
                  eww open bar;
                fi;
              done 
            '');
            always = true;
            notification = false;
          }
        ];

        assigns = {
          "9" = [{ class = "^qBittorrent$"; }];
        };
	
        keybindings = mkMerge [{
            # "${modifier}+r" = ''mode "resize"'';
            
            "${modifier}+u" = "workspace back_and_forth";
            "${modifier}+Shift+d" = "restart";
            "${modifier}+q" = "kill";
            "${modifier}+f" = "exec ${pkgs.alacritty}/bin/alacritty";
            "${modifier}+x" = "exec systemctl suspend";
            "${modifier}+r" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
            "${modifier}+Shift+r" = "exec ${pkgs.rofi}/bin/rofi -show window";

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
            "${modifier}+Control+h" = "resize shrink width 10 px or 10 ppt";
            "${modifier}+Control+j" = "resize grow height 10 px or 10 ppt";
            "${modifier}+Control+k" = "resize shrink height 10 px or 10 ppt";
            "${modifier}+Control+l" = "resize grow width 10 px or 10 ppt";

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
