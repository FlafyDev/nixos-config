{
  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    # hyprland.url = "github:flafydev/Hyprland/flafy2";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {hyprland, ...}: {
    modules = [hyprland.nixosModules.default];
    homeModules = [hyprland.homeManagerModules.default];

    overlays = _: [
      hyprland.overlays.default
      (_final: prev: {
        hyprland-wrapped = prev.writeShellScriptBin "hyprland" ''
            # export LIBVA_DRIVER_NAME="nvidia";
            # export GBM_BACKEND="nvidia-drm";
            # export __GLX_VENDOR_LIBRARY_NAME="nvidia";
          # export WLR_DRM_DEVICES=/dev/dri/card0

            export SDL_VIDEODRIVER=wayland
            export _JAVA_AWT_WM_NONREPARENTING=1;
            export XCURSOR_SIZE=24;
          # export WLR_NO_HARDWARE_CURSORS="1";
            export CLUTTER_BACKEND="wayland";
            export XDG_SESSION_TYPE="wayland";
            export QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
            export MOZ_ENABLE_WAYLAND="1";
            export WLR_BACKEND="vulkan";
            export QT_QPA_PLATFORM="wayland";
            export GDK_BACKEND="wayland";
            export TERM="foot";
            export NIXOS_OZONE_WL="1";
            ${hyprland.packages.${prev.system}.default}/bin/Hyprland "$@"
        '';
      })
    ];
  };

  system = { pkgs, ... }: {
    nix.settings = {
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      substituters = [
        "https://hyprland.cachix.org"
      ];
    };
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    programs.hyprland.enable = true;
  };

  home = {
    pkgs,
    theme,
    ...
  }: {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpaper
      # mako
      hyprland-wrapped
    ];
    gtk = {
      enable = true;
      cursorTheme = {
        name = "Bibata-Modern-Ice";
        size = 24;
        package = pkgs.bibata-cursors;
      };
    };
    xdg.configFile."hypr/hyprpaper.conf".text = let
      background =
        if theme == "Halloween"
        then "${pkgs.assets}/wallpapers/halloween.jpg"
        # else "${pkgs.assets}/wallpapers/forest.jpg";
        # TODO: add to assets git
        # else "/home/flafydev/Downloads/vecteezy_abstract-dark-pink-gradient-geometric-background-modern_4256686.jpg";
        else "/home/flafydev/Pictures/ferns.jpg";
    in ''
      preload = ${background}
      wallpaper = HDMI-A-1,${background}
      wallpaper = eDP-1,${background}
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      recommendedEnvironment = false;
      xwayland = {
        enable = true;
      };
      extraConfig = let
        activeBorder =
          if theme == "Halloween"
          then "0xFFd9b27c"
          else "rgb(314956)";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        socat = "${pkgs.socat}/bin/socat";
        # lidOpenCloseScript = pkgs.writeShellScript "lid-open-close" ''
        #   if grep -q open /proc/acpi/button/lid/LID0/state; then
        #     hyprctl keyword monitor eDP-1,1920x1080@60,0x0,1
        #   else
        #     hyprctl keyword monitor eDP-1,disable
        #   fi
        # '';
        autoMonitors = pkgs.writeShellScript "auto-monitors" ''
           if grep -q disconnected /sys/class/drm/card1-HDMI-A-1/status; then
             hyprctl keyword monitor eDP-1,1920x1080@60,0x0,1
             hyprctl keyword monitor HDMI-A-1,disable
             sleep 1
             eww kill; eww daemon; eww open bar;
           else
             hyprctl keyword monitor HDMI-A-1,1920x1080@60,0x0,1
             hyprctl keyword monitor eDP-1,disable
             sleep 1
             eww kill; eww daemon; eww open bar;
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
        # hyprlandFocusChange = pkgs.writeShellScript "hyprland-focus-change" ''
        #   ${pkgs.socat}/bin/socat -u "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" - |
        #   while read -r line; do if [ "''${line%>>*}" = "activewindow" ]; then
        #     pkill -9 -x tofi-run
        #     # pkill -9 -x tofi
        #   fi; done
        # '';
        compileWindowRule = window: rules: (builtins.concatStringsSep "\n" (map (rule: "windowrulev2=${rule},${window}") rules));
      in ''
        # monitor=,preferred,auto,1

        monitor=eDP-1,1920x1080@60,0x0,1,bitdepth,10
        monitor=HDMI-A-1,1920x1080@60,0x0,1,bitdepth,10

        # monitor=eDP-1,1920x1080@60,1920x0,1,mirror,DP-1

        # workspace=DP-1,1

        misc {
          no_vfr = false
          enable_swallow=false
          swallow_regex=^(foot)$
        }

        device:kmonad-kb-hyperx {
          kb_layout=us,il
        }

        device:kmonad-kb-laptop {
          kb_layout=us,il
        }

        device:my-kmonad-output {
          kb_layout=us,il
        }

        input {
            # kb_file=${./keyboard-xserver/layout.xkb}

            follow_mouse=1
            force_no_accel=1
            repeat_delay=200
            repeat_rate=40

            touchpad {
                natural_scroll=no
            }
        }

        general {
          sensitivity=0.2

          gaps_in=1
          gaps_out=20
          border_size=1
          # col.active_border=rgba(FF22BBaa) rgba(00000000) rgba(00000000) rgba(00000000) rgba(00000000) rgba(FF22BBaa) 45deg
          # col.active_border=rgba(FFFFFFFF) rgba(00000000) rgba(00000000) rgba(00000000) rgba(00000000) rgba(FFFFFFFF) 45deg
          # col.inactive_border=rgba(FFFFFF55) rgba(00000000) rgba(00000000) rgba(00000000) rgba(00000000) rgba(FFFFFF55) 45deg

          col.active_border=rgba(557755FF)
          col.inactive_border=rgba(758875FF)

          # col.active_border=gradient(rgb(314956), rgb(113355), 0.0, 1.0, 3.14/4.0)
          # col.inactive_border=rgba(FF22BB55) rgba(00000000) rgba(00000000) rgba(00000000) rgba(00000000) rgba(FF22BB55) 45deg
        }

        binds {
          workspace_back_and_forth=0
          allow_workspace_cycles=1
        }

        decoration {
          rounding=0
          blur=1
          blur_xray=1
          # blur_size=6
          # blur_passes=4
          blur_size=10
          blur_passes=3
          blur_ignore_opacity=0
          blur_new_optimizations=1
          drop_shadow=0
          shadow_range=20
          shadow_render_power=0
          col.shadow = 0x33220056
          shadow_offset=5 5
        }

        bezier=overshot,0.05,0.4,0.6,1.3
        bezier=mycurve,0.4, 0, 0.6, 1

        blurls=gtk-layer-shell

        animations {
          enabled=1
          animation=windowsMove,1,2,default

          animation=windowsIn,1,3,default,popin 10%

          animation=windowsOut,1,10,default,slide
          animation=fadeIn,1,3,default
          animation=fadeOut,0,10,default

          animation=border,0,3,default
          # animation=fade,1,3,default
          animation=workspaces,0,3,default,fade
        }

        dwindle {
            pseudotile=0 # enable pseudotiling on dwindle
            force_split=2
            preserve_split=1
            # no_gaps_when_only=1
        }

        # exec-once=${pkgs.hyprpaper}/bin/hyprpaper
        exec-once=${pkgs.batsignal}/bin/batsignal
        # exec-once=${autoMonitors}
        # exec-once=[workspace special] firefox
        exec-once=exec ${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store
        exec-once=hyprctl setcursor Bibata-Modern-Ice 24
        exec=eww open bar

        $WOBSOCK = $XDG_RUNTIME_DIR/wob.sock
        exec-once=rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | ${styledWob}

        bind=,Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
        bind=ALT,S,fullscreen
        bind=ALT,F,exec,${pkgs.foot}/bin/foot
        bind=ALT,X,exec,${pkgs.foot}/bin/foot --app-id sideterm
        bind=ALT,D,killactive,
        bind=ALT,E,exec,${pkgs.cinnamon.nemo}/bin/nemo
        bind=ALT,V,togglefloating,
        bind=ALT,ALT_L,exec,exec $(${pkgs.tofi}/bin/tofi-run)
        bind=ALT,W,exec,res=$(${pkgs.tofi-rbw}/bin/tofi-rbw) && wl-copy "$res"
        bind=ALT,C,exec,${pkgs.guifetch}/bin/guifetch
        bind=ALT,Z,exec,${pkgs.listen-blue}/bin/listen_blue
        bind=,Menu,exec,hyprctl switchxkblayout kmonad-kb-laptop next && hyprctl switchxkblayout kmonad-kb-hyperx next
        bind=SUPER,O,pseudo,
        bind=SUPER,M,exit,
        bind=SUPER,D,togglesplit,

        bind=CTRLALT,d,exec,echo -n 'hide' | ${socat} - UNIX-CONNECT:/tmp/screen_painter_socket.sock
        bind=CTRLALT,f,exec,echo -n 'show' | ${socat} - UNIX-CONNECT:/tmp/screen_painter_socket.sock

        bind=,XF86AudioPlay,exec,${playerctl} play-pause
        bind=,XF86AudioPrev,exec,${playerctl} previous
        bind=,XF86AudioNext,exec,${playerctl} next

        binde=,XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK
        binde=,XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK
        binde=,XF86AudioMute,exec,${pamixer} --toggle-mute && ( [ "$(${pamixer} --get-mute)" = "true" ] && echo 0 > $WOBSOCK ) || ${pamixer} --get-volume > $WOBSOCK

        binde=,XF86MonBrightnessUp,exec,${pkgs.lib.getExe pkgs.brightnessctl} set +5%
        binde=,XF86MonBrightnessDown,exec,${pkgs.lib.getExe pkgs.brightnessctl} set 5%-

        bindm=SUPER,mouse:272,movewindow
        bindm=SUPER,mouse:273,resizewindow

        bind=SUPER,L,movefocus,r
        bind=SUPER,H,movefocus,l
        bind=SUPER,K,movefocus,u
        bind=SUPER,J,movefocus,d

        binde=SUPERCTRL,L,resizeactive,150 0
        binde=SUPERCTRL,H,resizeactive,-150 0
        binde=SUPERCTRL,K,resizeactive,0 -150
        binde=SUPERCTRL,J,resizeactive,0 150

        bind=SUPERSHIFT,L,movewindow,r
        bind=SUPERSHIFT,H,movewindow,l
        bind=SUPERSHIFT,K,movewindow,u
        bind=SUPERSHIFT,J,movewindow,d

        bind=SUPER,U,workspace,previous
        bind=CTRLALT,1,workspace,1
        bind=CTRLALT,2,workspace,2
        bind=CTRLALT,3,workspace,3
        bind=CTRLALT,4,workspace,4
        bind=CTRLALT,5,workspace,5
        bind=CTRLALT,6,workspace,6
        bind=CTRLALT,7,workspace,7
        bind=CTRLALT,8,workspace,8
        bind=CTRLALT,9,workspace,9
        bind=CTRLALT,0,workspace,10

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

        ${compileWindowRule "class:^(sideterm)$" ["float" "move 60% 10" "size 750 350" "animation slide"]}
        ${compileWindowRule "class:^(guifetch)$" ["float" "animation slide" "move 10 10"]}
        ${compileWindowRule "class:^(listen_blue)$" ["size 813 695" "float" "center"]}
        ${compileWindowRule "floating:0" ["rounding 0"]}
        ${compileWindowRule "floating:1" ["rounding 5"]}
      '';
    };
  };
}
