{
  add = _: {
    overlays = _: [
      (_final: prev: {
        i3-alternating-layout = prev.callPackage ./i3-alternating-layout.nix {};
        xborder = prev.callPackage ./xborder.nix {};
      })
    ];
  };

  system = {pkgs, ...}: {
    services.xserver = {
      enable = true;
      #   # displayManager = {
      #   #     defaultSession = "none+i3";
      #   # };
      dpi = 96;

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          clipster
          dmenu
        ];
      };
    };
  };

  home = {
    pkgs,
    lib,
    ...
  }:
    with lib; {
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
          for_window [class="Funkin"] floating enable
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
            names = ["DejaVuSansMono" "Terminus"];
            style = "Bold Semi-Condensed";
            size = 19.5;
          };

          gaps = {
            left = 37; # for eww
            # smartGaps = true;
            inner = 8;
            outer = -8;
            # horizontal = houter - 16;
            # vertical = vouter - 16;
          };

          bars = [];

          startup = [
            {
              command = "${pkgs.feh}/bin/feh --bg-scale ${pkgs.assets}/wallpapers/forest.jpg";
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
            # {
            #   command = "${pkgs.xborder}/bin/xborder --border-width 2 --border-rgba 11ee8e66";
            #   always = true;
            #   notification = false;
            # }
            {
              command = "${(pkgs.writeShellScript "hide-bar-fullscreen" ''
                while :
                do
                  i3-msg -t subscribe -m '[ "window" ]' | while read -r arg; do
                    if [ $(${pkgs.jq}/bin/jq '.container.fullscreen_mode' <<< $arg) == '1' ]; then
                      eww close bar;
                    else
                      eww open bar;
                    fi
                  done

                  sleep 1
                done
              '')}";
              always = true;
              notification = false;
            }
          ];

          assigns = {
            "9" = [{class = "^qBittorrent$";}];
          };

          keybindings = let
            playerctl = "${pkgs.playerctl}/bin/playerctl";
            pactl = "${pkgs.pulseaudio}/bin/pactl";
          in
            mkMerge [
              {
                # "${modifier}+r" = ''mode "resize"'';

                "${modifier}+u" = "workspace back_and_forth";
                "${modifier}+a" = "fullscreen";
                "${modifier}+Shift+d" = "restart";
                "${modifier}+q" = "kill";
                "${modifier}+f" = "exec ${pkgs.alacritty}/bin/alacritty";
                "${modifier}+x" = "exec systemctl suspend";
                "${modifier}+r" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
                "${modifier}+Shift+r" = "exec ${pkgs.rofi}/bin/rofi -show window";
                "${modifier}+v" = "floating toggle";
                "${modifier}+g" = "exec ${pkgs.rofi-rbw}/bin/rofi-rbw";

                # Pulse Audio controls
                "XF86AudioRaiseVolume" = "exec --no-startup-id ${pactl} set-sink-volume 0 +5%";
                "XF86AudioLowerVolume" = "exec --no-startup-id ${pactl} set-sink-volume 0 -5%";
                "XF86AudioMute" = "exec --no-startup-id ${pactl} set-sink-mute 0 toggle";

                # Media player controls
                "XF86AudioPlay" = "exec ${playerctl} play-pause";
                "XF86AudioPause" = "exec ${playerctl} play-pause";
                "XF86AudioNext" = "exec ${playerctl} next";
                "XF86AudioPrev" = "exec ${playerctl} previous";

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
              (mkMerge (map (num: let
                strNum = builtins.toString num;
              in {
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
