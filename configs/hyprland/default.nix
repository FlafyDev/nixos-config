{
  inputs = {
    hyprland = {
      # url = "github:hyprwm/Hyprland/cc01550aff70a0cbee5b62db5f4a08789244998f";
      url = "github:hyprwm/Hyprland/v0.25.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };
  };

  add = {
    hyprland,
    hy3,
    ...
  }: {
    modules = [hyprland.nixosModules.default];
    homeModules = [hyprland.homeManagerModules.default];

    overlays = _: [
      # hyprland.overlays.default
      (final: prev: {
        hyprland = hyprland.packages.${prev.system}.default;
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
        # hyprlandPlugins = {
        #   inherit (hy3.packages.${prev.system}) hy3;
        # };
        hyprlandPlugins = final.callPackage ./plugins {};
        # hyprlandPlugins = let
        #   pkgs = import hyprland.inputs.nixpkgs {
        #     inherit (prev) system;
        #   };
        # in {
        #   hyprlens = pkgs.callPackage ./plugins/hyprlens.nix {
        #     inherit (hyprland.packages.${prev.system}) hyprland;
        #   };
        #   hy3 = pkgs.callPackage ./plugins/hy3.nix {
        #     inherit hyprland;
        #   };
        # };
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
    inputs,
    ...
  }: {
    home.packages = with pkgs; [
      hyprland-wrapped
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      recommendedEnvironment = false;
      xwayland.enable = true;
      plugins = with pkgs.hyprlandPlugins; [
        hyprlens
      ];
      # hyprlens
      extraConfig = let
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        compileWindowRule = window: rules: (builtins.concatStringsSep "\n" (map (rule: "windowrulev2=${rule},${window}") rules));
      in
        with theme.colors; ''
          # monitor=eDP-1,1920x1080@60,1920x0,1
          monitor=eDP-1,disable
          monitor=HDMI-A-1,1920x1080@60,0x0,1
          monitor=HDMI-A-1,addreserved,0,75,0,0

          plugin {
            hyprlens {
              background=/home/flafydev/Pictures/greenery/green3blur.png
              nearest=0
              tiled=0
            }
          }

          misc {
            vfr = true
            enable_swallow=false
            render_ahead_of_time=false
            swallow_regex=^(foot)$
            no_direct_scanout=true
            animate_manual_resizes=false
          }

          input {
              follow_mouse=1
              force_no_accel=1
              repeat_delay=200
              repeat_rate=40

              touchpad {
                  natural_scroll=no
              }

              # kb_layout = us,il
              # kb_options = grp:sclk_toggle
              kb_file = ${../../shared/layout.xkb}
          }

          general {
            sensitivity=0.2

            gaps_in=4
            gaps_out=8
            border_size=1

            layout=dwindle
            # col.active_border=rgba(${activeBorder.col}${activeBorder.opacity})
            col.active_border=rgb(aaff00) rgba(ffaa00ff) rgba(ffaa00ff) rgba(ffaa00ff) rgb(aaff00) 45deg
            col.inactive_border=rgba(${inactiveBorder.col}${inactiveBorder.opacity})
          }

          binds {
            workspace_back_and_forth=0
            allow_workspace_cycles=1
          }

          decoration {
            rounding=0
            blur=1
            blur_xray=1
            blur_size=17
            blur_passes=3
            blur_ignore_opacity=1
            blur_new_optimizations=1
            drop_shadow=1
            shadow_range=20
            shadow_render_power=2
            col.shadow = rgba(00000044)
            shadow_offset=0 0
          }

          bezier=mycurve,.32,.97,.53,.98
          bezier=easeInOut,.5,0,.5,1
          bezier=overshot,.32,.97,.37,1.16

          bezier=easeInOut,.5,0,.5,1

          animations {
            enabled=1
            animation=windowsMove,1,4,overshot

            animation=windowsIn,1,3,mycurve

            animation=windowsOut,1,10,mycurve,slide
            animation=fadeIn,1,3,mycurve
            animation=fadeOut,1,3,mycurve

            animation=border,1,5,mycurve
            # animation=fade,1,3,mycurve
            animation=workspaces,0,3,mycurve,fade
          }

          dwindle {
              pseudotile=0
              force_split=2
              preserve_split=1
              default_split_ratio=1.3
          }

          master {
            new_is_master=false
            new_on_top=false
            no_gaps_when_only=false
            orientation=top
            mfact=0.6
            always_center_master=false
          }

          exec-once=${pkgs.swaybg}/bin/swaybg --image ${theme.wallpaper}
          # exec-once=[workspace special] firefox
          exec-once=${pkgs.foot}/bin/foot --server
          exec-once=exec ${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store
          exec-once=hyprctl setcursor Bibata-Modern-Ice 24

          bind=,Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
          bind=ALT,S,fullscreen
          bind=ALT,F,exec,${pkgs.foot}/bin/footclient
          bind=ALT,V,exec,${pkgs.foot}/bin/footclient --app-id sideterm
          bind=ALT,D,killactive,
          bind=ALT,G,togglefloating,
          bind=,Menu,exec,hyprctl switchxkblayout kmonad-kb-laptop next && hyprctl switchxkblayout kmonad-kb-hyperx next
          # bind=ALT,O,pseudo,
          bind=SHIFTALT,SEMICOLON,exit,
          bind=ALT,A,togglesplit,

          bind=,XF86AudioPlay,exec,${playerctl} play-pause
          bind=,XF86AudioPrev,exec,${playerctl} previous
          bind=,XF86AudioNext,exec,${playerctl} next

          binde=,XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK
          binde=,XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK
          binde=,XF86AudioMute,exec,${pamixer} --toggle-mute && ( [ "$(${pamixer} --get-mute)" = "true" ] && echo 0 > $WOBSOCK ) || ${pamixer} --get-volume > $WOBSOCK

          binde=,XF86MonBrightnessUp,exec,${pkgs.lib.getExe pkgs.brightnessctl} set +5%
          binde=,XF86MonBrightnessDown,exec,${pkgs.lib.getExe pkgs.brightnessctl} set 5%-

          bindm=ALT,mouse:272,movewindow
          bindm=ALT,mouse:273,resizewindow

          bind=ALT,H,movefocus,l
          bind=ALT,J,movefocus,d
          bind=ALT,K,movefocus,u
          bind=ALT,L,movefocus,r

          binde=ALTSHIFT,H,resizeactive,-150 0
          binde=ALTSHIFT,J,resizeactive,0 150
          binde=ALTSHIFT,K,resizeactive,0 -150
          binde=ALTSHIFT,L,resizeactive,150 0

          bind=ALTCTRL,L,movewindow,r
          bind=ALTCTRL,H,movewindow,l
          bind=ALTCTRL,K,movewindow,u
          bind=ALTCTRL,J,movewindow,d

          bind=SUPER,U,workspace,previous
          bind=ALT,Q,workspace,1
          bind=ALT,W,workspace,2
          bind=ALT,E,workspace,3
          bind=ALT,R,workspace,4
          bind=ALT,T,workspace,5
          bind=ALT,Z,workspace,6
          bind=ALT,X,workspace,7
          bind=ALT,C,workspace,8
          bind=ALT,V,workspace,9
          bind=ALT,B,workspace,10

          bind=ALTSHIFT,Q,movetoworkspace,1
          bind=ALTSHIFT,W,movetoworkspace,2
          bind=ALTSHIFT,E,movetoworkspace,3
          bind=ALTSHIFT,R,movetoworkspace,4
          bind=ALTSHIFT,T,movetoworkspace,5
          bind=ALTSHIFT,Z,movetoworkspace,6
          bind=ALTSHIFT,X,movetoworkspace,7
          bind=ALTSHIFT,C,movetoworkspace,8
          bind=ALTSHIFT,V,movetoworkspace,9
          bind=ALTSHIFT,B,movetoworkspace,10

          # Specific window rules
          ${compileWindowRule "class:^(sideterm)$" ["float" "move 60% 10" "size 750 350" "animation slide"]}
          ${compileWindowRule "class:^(guifetch)$" ["float" "animation slide" "move 10 10"]}
          ${compileWindowRule "class:^(listen_blue)$" ["size 813 695" "float" "center"]}
          ${compileWindowRule "class:^(neovide)$" ["tile"]}
          ${compileWindowRule "class:^(firefox)$" ["opacity 0.999 0.999"]}

          # General window rules
          ${compileWindowRule "floating:0" ["rounding 0"]}
          ${compileWindowRule "floating:1" ["rounding 5"]}
          ${compileWindowRule "floating:0" ["noshadow"]}
          layerrule = noanim, ^(selection)$
        '';
    };
  };
}