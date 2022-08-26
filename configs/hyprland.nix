{
  system = { ... }: {
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
    
    programs.hyprland = {
      enable = true;
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      CLUTTER_BACKEND = "wayland";
      XDG_SESSION_TYPE = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_BACKEND = "vulkan";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      # WLR_DRM_DEVICES = "/dev/dri/card1";
    };
  };

  home = { pkgs, ... }: {
    home.packages = [ pkgs.hyprpaper ];
    xdg.configFile."hypr/hyprpaper.conf".text = let
      background = ../assets/background2.png;
    in ''
      preload = ${background}
      wallpaper = HDMI-A-1,${background}
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = true;
      extraConfig = let 
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        pulsemixer = "${pkgs.pulsemixer}/bin/pulsemixer";
      in ''
        monitor=,preferred,auto,1
        monitor=eDP-1,disable
        workspace=DP-1,1

        misc {
          no_vfr = false;
        }

        input {
            kb_file=${./keyboard/layout.xkb}

            follow_mouse=1
            force_no_accel=1
            repeat_delay=200

            touchpad {
                natural_scroll=no
            }
        }

        general {
            sensitivity=0.3
            main_mod=SUPER

            gaps_in=5
            gaps_out=20
            border_size=2
            col.active_border=0x6611ee8e
            col.inactive_border=0x00333333
        }

        decoration {
            rounding=10
            blur=1
            blur_size=2
            blur_passes=1
            blur_new_optimizations=1
        }

        bezier=overshot,0.05,0.9,0.1,1.1
        bezier=mycurve,0.4, 0, 0.6, 1

        animations {
            enabled=1
            animation=windows,1,7,default,slide
            animation=border,1,10,default
            #animation=fade,1,10,default
            animation=workspaces,1,4,default,slidevert
        }

        dwindle {
            pseudotile=0 # enable pseudotiling on dwindle
            force_split=2
            no_gaps_when_only=1
        }

        exec-once=${pkgs.hyprpaper}/bin/hyprpaper 
 
        bind=,Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
        bind=SUPER,F,exec,${pkgs.foot}/bin/foot
        bind=SUPER,Q,killactive,
        bind=SUPER,M,exit,
        bind=SUPER,E,exec,nautilus --new-window
        bind=SUPER,V,togglefloating,
        bind=SUPER,R,exec,${pkgs.wofi}/bin/wofi --show drun -o DP-3
        bind=SUPER,P,pseudo,
        bind=,XF86AudioPlay,exec,${playerctl} play-pause
        bind=,XF86AudioPrev,exec,${playerctl} previous
        bind=,XF86AudioNext,exec,${playerctl} next
        bind=,XF86AudioRaiseVolume,exec,${pulsemixer} --change-volume +2
        bind=,XF86AudioLowerVolume,exec,${pulsemixer} --change-volume -2
        bind=,XF86AudioMute,exec,${pulsemixer} --toggle-mute

        bind=SUPER,L,movefocus,r
        bind=SUPER,H,movefocus,l
        bind=SUPER,K,movefocus,u
        bind=SUPER,J,movefocus,d

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


    home.sessionVariables = {
      _JAVA_AWT_WM_NONREPARENTING = 1;
      XCURSOR_SIZE = 1;
    };
  };
}

