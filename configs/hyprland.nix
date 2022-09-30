{
  system = { ... }: {
    # nix.settings = {
    #   substituters = ["https://hyprland.cachix.org"];
    #   trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    # };
    
    # programs.hyprland = {
    #   enable = true;
    # };

    # environment.sessionVariables = {
    #   LIBVA_DRIVER_NAME = "nvidia";
    #   CLUTTER_BACKEND = "wayland";
    #   XDG_SESSION_TYPE = "wayland";
    #   QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    #   MOZ_ENABLE_WAYLAND = "1";
    #   GBM_BACKEND = "nvidia-drm";
    #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    #   WLR_NO_HARDWARE_CURSORS = "1";
    #   WLR_BACKEND = "vulkan";
    #   QT_QPA_PLATFORM = "wayland";
    #   GDK_BACKEND = "wayland";
    #   # WLR_DRM_DEVICES = "/dev/dri/card1";
    # };
  };

  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpaper 
      mako
      (pkgs.writeShellScriptBin "hyprland" ''
        export _JAVA_AWT_WM_NONREPARENTING=1;
        export XCURSOR_SIZE=1;
        export LIBVA_DRIVER_NAME="nvidia";
        export CLUTTER_BACKEND="wayland";
        export XDG_SESSION_TYPE="wayland";
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
        export MOZ_ENABLE_WAYLAND="1";
        export GBM_BACKEND="nvidia-drm";
        export __GLX_VENDOR_LIBRARY_NAME="nvidia";
        export WLR_NO_HARDWARE_CURSORS="1";
        export WLR_BACKEND="vulkan";
        export QT_QPA_PLATFORM="wayland";
        export GDK_BACKEND="wayland";
        Hyprland "$@"
      '')
    ];
    xdg.configFile."hypr/hyprpaper.conf".text = let
      background = ../assets/forest.jpg;
    in ''
      preload = ${background}
      wallpaper = HDMI-A-1,${background}
      wallpaper = eDP-1,${background}
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
      extraConfig = let 
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        lidOpenCloseScript = pkgs.writeShellScript "lid-open-close" ''
          if grep -q open /proc/acpi/button/lid/LID0/state; then 
            hyprctl keyword monitor eDP-1,1920x1080@60,0x0,1
          else               
            hyprctl keyword monitor eDP-1,disable
          fi 
        '';
        styledWob = pkgs.writeShellScript "styled-wob" ''
          ${pkgs.wob}/bin/wob --anchor "top" \
            --anchor "right" \
            --width  300 \
            --height 40 \
            --offset 0 \
            --border 0 \
            --margin 10 \
            --background-color '#eeeeeeFF' \
            --bar-color '#87afd7FF'
        '';
        hyprlandFocusChange = pkgs.writeShellScript "hyprland-focus-change" ''
          ${pkgs.socat}/bin/socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |
          while read -r line; do if [ "''${line%>>*}" = "activewindow" ]; then
            pkill -9 -x tofi-drun
          fi; done
        '';
      in ''
        # monitor=,preferred,auto,1

        monitor=HDMI-A-1,1920x1080@60,0x0,1
        monitor=eDP-1,disable

        # monitor=eDP-1,1920x1080@60,1920x0,1,mirror,DP-1
        # workspace=DP-1,1

        misc {
          no_vfr = false;
        }

        input {
            kb_file=${./keyboard-xserver/layout.xkb}

            follow_mouse=1
            force_no_accel=1
            repeat_delay=200
            repeat_rate=40

            touchpad {
                natural_scroll=no
            }
        }

        general {
            sensitivity=0.3

            gaps_in=5
            gaps_out=5
            border_size=1
            col.active_border=0xFF817f7f
            col.inactive_border=0x00000000
        }

        binds {
          workspace_back_and_forth=0
          allow_workspace_cycles=1
        }

        decoration {
            rounding=0
            blur=1
            blur_size=10
            blur_passes=3
            blur_new_optimizations=1
        }

        bezier=overshot,0.05,0.9,0.1,1.1
        bezier=mycurve,0.4, 0, 0.6, 1

        animations {
            enabled=0
            animation=windows,1,7,default,slide
            animation=border,1,10,default
            #animation=fade,1,10,default
            animation=workspaces,1,4,default,slidevert
        }

        dwindle {
            pseudotile=0 # enable pseudotiling on dwindle
            force_split=2
            # no_gaps_when_only=1
        }

        exec-once=${pkgs.hyprpaper}/bin/hyprpaper 
        exec-once=${pkgs.batsignal}/bin/batsignal 
        exec-once=${lidOpenCloseScript}
        exec-once=${hyprlandFocusChange}
        exec=eww open bar

        $WOBSOCK = $XDG_RUNTIME_DIR/wob.sock
        exec-once=rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | ${styledWob}

        bind=,Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
        bind=SUPER,A,fullscreen
        bind=SUPER,F,exec,${pkgs.foot}/bin/foot
        bind=SUPER,Q,killactive,
        bind=SUPER,M,exit,
        bind=SUPER,E,exec,nautilus --new-window
        bind=SUPER,V,togglefloating,
        bind=SUPER,R,exec,exec $(${pkgs.tofi}/bin/tofi-drun)
        bind=SUPER,P,pseudo,
        bind=,XF86AudioPlay,exec,${playerctl} play-pause
        bind=,XF86AudioPrev,exec,${playerctl} previous
        bind=,XF86AudioNext,exec,${playerctl} next

        bind=,XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK
        bind=,XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK
        bind=,XF86AudioMute,exec,${pamixer} --toggle-mute && ( [ "$(${pamixer} --get-mute)" = "true" ] && echo 0 > $WOBSOCK ) || ${pamixer} --get-volume > $WOBSOCK

        bindm=SUPER,mouse:272,movewindow
        bindm=SUPER,mouse:273,resizewindow

        bind=SUPER,L,movefocus,r
        bind=SUPER,H,movefocus,l
        bind=SUPER,K,movefocus,u
        bind=SUPER,J,movefocus,d

        bind=SUPERCTRL,L,resizeactive,150 0
        bind=SUPERCTRL,H,resizeactive,-150 0
        bind=SUPERCTRL,K,resizeactive,0 -150
        bind=SUPERCTRL,J,resizeactive,0 150

        bind=SUPERSHIFT,L,movewindow,r
        bind=SUPERSHIFT,H,movewindow,l
        bind=SUPERSHIFT,K,movewindow,u
        bind=SUPERSHIFT,J,movewindow,d

        bind=SUPER,U,workspace,previous
        bind=SUPER,1,workspace,1
        bind=SUPER,2,workspace,2
        bind=SUPER,3,workspace,3
        bind=SUPER,4,workspace,4
        bind=SUPER,5,workspace,5
        bind=SUPER,6,workspace,6
        bind=SUPER,7,workspace,7
        bind=SUPER,8,workspace,8
        bind=SUPER,9,workspace,9
        bind=SUPER,0,workspace,10

        bind=SUPERSHIFT,1,movetoworkspace,1
        bind=SUPERSHIFT,2,movetoworkspace,2
        bind=SUPERSHIFT,3,movetoworkspace,3
        bind=SUPERSHIFT,4,movetoworkspace,4
        bind=SUPERSHIFT,5,movetoworkspace,5
        bind=SUPERSHIFT,6,movetoworkspace,6
        bind=SUPERSHIFT,7,movetoworkspace,7
        bind=SUPERSHIFT,8,movetoworkspace,8
        bind=SUPERSHIFT,9,movetoworkspace,9
        bind=SUPERSHIFT,0,movetoworkspace,10

        bind=SUPER,mouse_down,workspace,e+1
        bind=SUPER,mouse_up,workspace,e-1
      '';
    };
  };
}

