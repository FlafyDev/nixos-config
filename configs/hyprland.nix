{
  inputs = {
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.24.0";
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
            export SDL_VIDEODRIVER=wayland
            export _JAVA_AWT_WM_NONREPARENTING=1;
            export XCURSOR_SIZE=24;
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

  system = _: {
    nix.settings = {
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      substituters = [
        "https://hyprland.cachix.org"
      ];
    };
    xdg.portal.enable = true;
    programs.hyprland.enable = true;
  };

  home = {
    pkgs,
    theme,
    ...
  }: {
    home.packages = with pkgs; [
      hyprland-wrapped
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      recommendedEnvironment = false;
      xwayland.enable = true;
      extraConfig = let
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        compileWindowRule = window: rules: (builtins.concatStringsSep "\n" (map (rule: "windowrulev2=${rule},${window}") rules));
      in ''
        monitor=eDP-1,1920x1080@60,0x0,1
        monitor=HDMI-A-1,1920x1080@60,1920x0,1

        misc {
          vfr = true
          enable_swallow=false
          render_ahead_of_time=false
          swallow_regex=^(foot)$
          no_direct_scanout=true
        }

        device:my-kmonad-output {
          kb_layout=us,il
        }

        input {
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

          col.active_border=rgba(29A4BDFF)
          col.inactive_border=rgba(75758555)
        }

        binds {
          workspace_back_and_forth=0
          allow_workspace_cycles=1
        }

        decoration {
          rounding=0
          blur=1
          blur_xray=1
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

        animations {
          enabled=1
          animation=windowsMove,1,2,default

          animation=windowsIn,1,3,default,popin 10%

          animation=windowsOut,1,10,default,slide
          animation=fadeIn,1,3,default
          animation=fadeOut,0,10,default

          animation=border,1,5,default
          # animation=fade,1,3,default
          animation=workspaces,0,3,default,fade
        }

        dwindle {
            pseudotile=0
            force_split=2
            preserve_split=1
        }

        exec-once=sway --image ${theme.wallpaper}
        exec-once=[workspace special] firefox
        exec-once=exec ${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store
        exec-once=hyprctl setcursor Bibata-Modern-Ice 24

        bind=,Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
        bind=ALT,S,fullscreen
        bind=ALT,F,exec,${pkgs.foot}/bin/foot
        bind=ALT,X,exec,${pkgs.foot}/bin/foot --app-id sideterm
        bind=ALT,D,killactive,
        bind=ALT,E,exec,${pkgs.cinnamon.nemo}/bin/nemo
        bind=ALT,V,togglefloating,
        bind=ALT,ALT_L,exec,exec $(${pkgs.tofi}/bin/tofi-run)
        bind=,Menu,exec,hyprctl switchxkblayout kmonad-kb-laptop next && hyprctl switchxkblayout kmonad-kb-hyperx next
        bind=SUPER,O,pseudo,
        bind=SUPER,M,exit,
        bind=SUPER,D,togglesplit,

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
