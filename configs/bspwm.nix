{
  inputs = {
    bspwm-rounded = {
      url = "github:phuhl/bspwm-rounded";
      flake = false;
    };
  };

  add = {bspwm-rounded, ...}: {
    overlays = _: [
      (final: prev: {
        bspwm-rounded = prev.bspwm.overrideAttrs (_: {
          src = bspwm-rounded;
        });
      })
    ];
  };

  system = {pkgs, ...}: {
    services.xserver = {
      enable = true;
      dpi = 96;

      displayManager = {
        defaultSession = "none+bspwm";
      };

      windowManager.bspwm = {
        enable = true;
        package = pkgs.bspwm-rounded;
      };

      # displayManager.gdm.enable = true;
    };
  };

  home = {
    pkgs,
    lib,
    ...
  }: let
    workspaces = 6;
  in {
    xsession.windowManager.bspwm = {
      enable = true;
      package = pkgs.bspwm-rounded;
      monitors = {
        HDMI-1 = map toString (lib.lists.range 1 workspaces);
      };
      startupPrograms = let
        compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
          ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./keyboard-xserver/layout.xkb} $out
        '';
      in [
        "${pkgs.feh}/bin/feh --bg-scale ${pkgs.assets}/wallpapers/forest.jpg"
        "xsetroot -cursor_name left_ptr"
        "eww open bar"
        "sxhkd"
        "${pkgs.xorg.xset}/bin/xset r rate 200 40"
        "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY"
        (toString (pkgs.writeShellScript "bspwm-hide-eww-bar-fullscreen" ''
          bspc subscribe desktop_focus node_state node_focus | while read _; do
            if bspc query -T -n | grep '"state":"fullscreen"' -q; then
              xdotool search --class eww-bar windowunmap
            else
              xdotool search --class eww-bar windowmap
            fi;
          done
        ''))
      ];
    };

    services.sxhkd = {
      enable = true;
      keybindings = let
        mod = "super";
        resizePixels = "20";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
      in {
        "${mod} + m" = "bspc quit";
        "${mod} + q" = "bspc node -c";
        "${mod} + {d,shift + d,v,a}" = "bspc node -t {tiled,pseudo_tiled,floating,~fullscreen}";
        "${mod} + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}";
        "${mod} + {_,shift + }{j,k,l,'}" = "bspc node -{f,s} {west,south,north,east}";

        "${mod} + {o,i}" = "bspc wm -h off; bspc node {older,newer} -f; bspc wm -h on";
        "${mod} + ctrl + {j,k,l,'}" = "bspc node -z {left -${resizePixels} 0,bottom 0 ${resizePixels},top 0 -${resizePixels},right ${resizePixels} 0}";
        "${mod} + ctrl + shift + {j,k,l,'}" = "bspc node -z {right -${resizePixels} 0,top 0 ${resizePixels},bottom 0 -${resizePixels},left ${resizePixels} 0}";

        "${mod} + f" = "WINIT_X11_SCALE_FACTOR=1 alacritty";
        "${mod} + s" = "firefox";
        "${mod} + e" = "nautilus";
        "${mod} + r" = "rofi -show drun";
        "${mod} + w" = "pavucontrol";

        "${mod} + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '{1-9,10}'";
        "${mod} + p" = "${pkgs.maim}/bin/maim -s -u -o | xclip -selection clipboard -t image/png -i";

        # Pulse Audio controls
        "XF86AudioRaiseVolume" = "${pactl} set-sink-volume 0 +5%";
        "XF86AudioLowerVolume" = "${pactl} set-sink-volume 0 -5%";
        "XF86AudioMute" = "${pactl} set-sink-mute 0 toggle";

        # Media player controls
        "XF86AudioPlay" = "${playerctl} play-pause";
        "XF86AudioPause" = "${playerctl} play-pause";
        "XF86AudioNext" = "${playerctl} next";
        "XF86AudioPrev" = "${playerctl} previous";
      };
    };
  };
}
