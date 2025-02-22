{
  lib,
  config,
  inputs,
  pkgs,
  theme,
  utils,
  ...
}: let
  cfg = config.display.hyprland;
  plugins = pkgs.callPackage ./plugins {};
  inherit (lib) mkEnableOption mkOption mkIf mkMerge types mapAttrsToList;
  inherit (utils) flPkgs';


  powerButtonScript = pkgs.writeShellScript "power-button" ''
    hyprctl dispatch dpms toggle
  '';
in {
  options.display.hyprland = {
    enable = mkEnableOption "hyprland";
    monitors = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        A list of monitors.
      '';
    };
    headlessXorg = {
      enable = mkEnableOption "hyprland-headless-xorg";
      num = mkOption {
        type = with types; int;
        default = 243;
        description = ''
          The servernum of the Xorg server to run in headless mode.
        '';
      };
    };
    fromNixpkgs = mkOption {
      type = with types; bool;
      default = false;
      description = ''
        Get hyprland from nixpkgs
      '';
    };
  };

  config = mkMerge [
    {
      inputs = {
        # inputs.flutter_background_bar = {
        #   url = "github:flafydev/flutter_background_bar";
        # };
        # hypr-dynamic-cursors = {
        #   url = "github:VirtCode/hypr-dynamic-cursors";
        #   inputs.hyprland.follows = "hyprland"; # to make sure that the plugin is built for the correct version of hyprland
        # };
        hyprland = {
          # url = "github:hyprwm/Hyprland/v0.34.0";
          # url = "github:hyprwm/Hyprland/045c3fbd854090b2b60ca025fedd3e62498ed1ec";
          # url = "github:hyprwm/Hyprland/53afa0bb62888aa3580a1e0d9e3bce5d05b9af80?submodules=1";

          url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
          # url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
          # inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    }
    (mkIf cfg.enable {
      # os.environment.systemPackages = [
      #   (elib.flPkgs inputs.flutter_background_bar)
      # ];

      os = {
        xdg.portal.enable = true;
        xdg.portal.extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
        programs.hyprland = {
          enable = true;
          package = mkIf (!cfg.fromNixpkgs) inputs.hyprland.packages.${pkgs.system}.hyprland;
          portalPackage = mkIf (!cfg.fromNixpkgs) inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
        };
        nix.settings = mkIf (!cfg.fromNixpkgs) {
          substituters = ["https://hyprland.cachix.org"];
          trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
        };
      };

      hm.wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = mkIf (!cfg.fromNixpkgs) inputs.hyprland.packages.${pkgs.system}.hyprland;
        plugins = with plugins; [
          # (flPkgs' inputs.hypr-dynamic-cursors ["hypr-dynamic-cursors"])
        ];
        settings = let
          playerctl = "${pkgs.playerctl}/bin/playerctl";
          pactl = "${pkgs.pulseaudio}/bin/pactl";
          pamixer = "${pkgs.pamixer}/bin/pamixer";
        in {
          bezier = [
            "mycurve,.32,.97,.53,.98"
            "expoOut,0.19,1.0,0.22,1.0"
            "overshot,.32,.97,.37,1.16"
            "easeInOut,.5,0,.5,1"
          ];
          env = mapAttrsToList (name: value: "${name},${toString value}") {
            # WLR_NO_HARDWARE_CURSORS = 1; # For Sunshine... Let's see if I notice anything...
            SDL_VIDEODRIVER = "wayland";
            _JAVA_AWT_WM_NONREPARENTING = 1;
            # WLR_DRM_NO_ATOMIC = 1;
            XCURSOR_SIZE = 24;
            CLUTTER_BACKEND = "wayland";
            XDG_SESSION_TYPE = "wayland";
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
            MOZ_ENABLE_WAYLAND = "1";
            QT_QPA_PLATFORM = "wayland";
            GDK_BACKEND = "wayland";
            TERM = "foot";
            NIXOS_OZONE_WL = "1";
          };
          layerrule = [
            "noanim, ^(selection)$"
            "blur,^(anyrun)$"
            "ignorealpha ${toString (theme.popupBackgroundColor.toNormA - 0.01)},^(anyrun)$"
          ];
          monitor = cfg.monitors;
          plugins = {
            # hyprlens = {
            #   background = toString theme.wallpaperBlurred;
            #   nearest = 0;
            #   tiled = 0;
            # };
          };
          misc = {
            vfr = true;
            enable_swallow = true;
            swallow_regex = "^(foot)$";
            animate_manual_resizes = false;
            force_default_wallpaper = 0;
          };
          input = {
            follow_mouse = 1;
            # force_no_accel = 1;
            repeat_delay = 200;
            repeat_rate = 40;

            touchpad = {
              natural_scroll = false;
            };

            sensitivity = -1.0;
            # kb_layout = us,il
            # kb_options = grp:sclk_toggle
            kb_file = toString ./keyboard.xkb;
          };
          general = {

            gaps_in = 1;
            gaps_out = 2;
            border_size = 1;
            allow_tearing = true;

            layout = "dwindle";
            # col.active_border=rgb(aaff00) rgba(ffaa00ff) rgba(ffaa00ff) rgba(ffaa00ff) rgb(aaff00) 45deg
            "col.active_border" = "rgba(${theme.borderColor.active.toHexRGBA})";
            "col.inactive_border" = "rgba(${theme.borderColor.inactive.toHexRGBA})";
          };
          binds = {
            workspace_back_and_forth = 0;
            allow_workspace_cycles = 1;
          };
          decoration = {
            rounding = 0;
            dim_inactive = true;
            dim_strength = 0.0;
            drop_shadow = 1;
            shadow_range = 20;
            shadow_render_power = 2;
            "col.shadow" = "rgba(00000044)";
            shadow_offset = "0 0";
            blur = {
              enabled = 1;
              size = 4;
              passes = 4;
              ignore_opacity = 1;
              xray = 1;
              new_optimizations = 1;
              noise = 0.03;
              contrast = 1.0;
            };
          };
          animations = {
            enabled = 1;
            animation = [
              "windowsMove,1,4,expoOut"
              "windowsIn,1,4,expoOut"
              "windowsOut,0,4,mycurve"
              "fadeIn,0,3,mycurve"
              "fadeOut,0,3,mycurve"
              "fadeDim,1,1,expoOut"
              "border,0,4,expoOut"
              "workspaces,0,2,expoOut,fade"
            ];
          };
          dwindle = {
            pseudotile = 0;
            force_split = 2;
            preserve_split = 1;
            default_split_ratio = 1.3;
          };
          master = {
            # new_is_master = false;
            new_on_top = false;
            no_gaps_when_only = false;
            orientation = "top";
            mfact = 0.6;
            always_center_master = false;
          };
          exec-once = [
            "${pkgs.mako}/bin/mako"
            "${pkgs.foot}/bin/foot --server"
            # "${elib.flPkgs inputs.flutter_background_bar}/bin/flutter_background_bar"
            "hyprctl setcursor Bibata-Modern-Ice 24"

            (mkIf cfg.headlessXorg.enable "${pkgs.xorg.xorgserver}/bin/Xvfb :${toString cfg.headlessXorg.num} -screen 0 1024x768x24")

            "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store #Stores only text data"
            "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.xclip}/bin/xclip -selection clipboard"
            "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store #Stores only image data"
            "${pkgs.swaybg}/bin/swaybg --image ${theme.wallpaper} --mode fill"
            "${pkgs.snapcast}/bin/snapclient --host 10.0.0.2 -s 3 --port 1704"
            # "[workspace special] firefox"
          ];
          bind = [
            '',Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png''
            "SUPER,S,fullscreen"
            "SUPER,F,exec,${pkgs.foot}/bin/foot"
            "SUPER,V,exec,${pkgs.foot}/bin/footclient --app-id sideterm"
            "SUPER,BACKSPACE,exec,${pkgs.foot}/bin/footclient --app-id middleterm"
            "SUPER,D,killactive,"
            "SUPER,G,togglefloating,"
            ",Menu,exec,hyprctl switchxkblayout kmonad-kb-laptop next && hyprctl switchxkblayout kmonad-kb-hyperx next"

            ",XF86PowerOff,exec,${powerButtonScript}"

            "SUPER,SEMICOLON,exec,anyrun"

            "SHIFTSUPER,SEMICOLON,exit,"
            "SUPER,A,togglesplit,"

            ",XF86AudioPlay,exec,${playerctl} play-pause"
            ",XF86AudioPrev,exec,${playerctl} previous"
            ",XF86AudioNext,exec,${playerctl} next"

            "SUPER,H,movefocus,l"
            "SUPER,J,movefocus,d"
            "SUPER,K,movefocus,u"
            "SUPER,L,movefocus,r"

            "SUPERCTRL,L,swapwindow,r"
            "SUPERCTRL,H,swapwindow,l"
            "SUPERCTRL,K,swapwindow,u"
            "SUPERCTRL,J,swapwindow,d"

            "SUPER,M,workspace,previous"
            "SUPER,Q,workspace,1"
            "SUPER,W,workspace,2"
            "SUPER,E,workspace,3"
            "SUPER,R,workspace,4"
            "SUPER,T,workspace,5"
            "SUPER,Y,workspace,6"
            "SUPER,U,workspace,7"
            "SUPER,I,workspace,8"
            "SUPER,O,workspace,9"
            "SUPER,P,workspace,10"

            "SUPERSHIFT,Q,movetoworkspace,1"
            "SUPERSHIFT,W,movetoworkspace,2"
            "SUPERSHIFT,E,movetoworkspace,3"
            "SUPERSHIFT,R,movetoworkspace,4"
            "SUPERSHIFT,T,movetoworkspace,5"
            "SUPERSHIFT,Y,movetoworkspace,6"
            "SUPERSHIFT,U,movetoworkspace,7"
            "SUPERSHIFT,I,movetoworkspace,8"
            "SUPERSHIFT,O,movetoworkspace,9"
            "SUPERSHIFT,P,movetoworkspace,10"
          ];
          binde = [
            "SUPERSHIFT,H,resizeactive,-150 0"
            "SUPERSHIFT,J,resizeactive,0 150"
            "SUPERSHIFT,K,resizeactive,0 -150"
            "SUPERSHIFT,L,resizeactive,150 0"

            ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK"
            ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5% && ${pactl} get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print substr($5, 1, length($5)-1)}' > $WOBSOCK"
            '',XF86AudioMute,exec,${pamixer} --toggle-mute && ( [ "$(${pamixer} --get-mute)" = "true" ] && echo 0 > $WOBSOCK ) || ${pamixer} --get-volume > $WOBSOCK''

            ",XF86MonBrightnessUp,exec,${pkgs.lib.getExe pkgs.brightnessctl} set +5%"
            ",XF86MonBrightnessDown,exec,${pkgs.lib.getExe pkgs.brightnessctl} set 5%-"
          ];
          bindm = [
            "SUPER,mouse:272,movewindow"
            "SUPER,mouse:273,resizewindow"
          ];
          # device = [
          #   {
          #     name = "logitech-g502-hero-gaming-mouse";
          #     accel_profile = "flat";
          #     sensitivity = 0.2;
          #   }
          #   {
          #     name = "logitech-g502-hero-gaming-mouse-keyboard-1";
          #     accel_profile = "flat";
          #     sensitivity = 0.2;
          #   }
          # ];
          windowrulev2 = let
            rulesForWindow = window: map (rule: "${rule},${window}");
          in
            []
            # Specific window rules
            ++ (rulesForWindow "title:^()$,class:^(steam)$" ["stayfocused" "minsize 1 1"])
            ++ (rulesForWindow "class:^(sideterm)$" ["float" "move 60% 10" "size 750 350" "animation slide"])
            # ++ (rulesForWindow "class:^(looking-glass-client)$" ["immediate"])
            ++ (rulesForWindow "class:^(middleterm)$" ["float" "size 750 550" "animation slide"])
            ++ (rulesForWindow "class:^(guifetch)$" ["float" "animation slide" "move 10 10"])
            ++ (rulesForWindow "class:^(listen_blue)$" ["size 813 695" "float" "center"])
            ++ (rulesForWindow "class:^(neovide)$" ["tile"])
            ++ (rulesForWindow "class:^(firefox)$" ["opacity 0.999 0.999"])
            # General window rules
            ++ (rulesForWindow "floating:0" ["rounding 0"])
            ++ (rulesForWindow "floating:1" ["rounding 5"])
            ++ (rulesForWindow "floating:0" ["noshadow"]);
        };
      };
    })
  ];
}
