{
  system = {pkgs, ...}: {
    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      # gtkUsePortal = true;
    };
    environment.systemPackages = with pkgs; [
      glxinfo
      vulkan-tools
      glmark2
    ];

    # enable sway window manager
    # programs.sway = {
    #   enable = true;
    #   wrapperFeatures.gtk = true;
    # };
  };

  home = {
    pkgs,
    lib,
    ...
  }:
    with lib; {
      wayland.windowManager.sway = {
        enable = true;
        # package = pkgs.sway-borders;
        xwayland = true;
        extraOptions = ["--unsupported-gpu"];
        config = let
          modifier = "Mod4";
        in {
          inherit modifier;
          fonts = {
            names = ["DejaVuSansMono" "Terminus"];
            style = "Bold Semi-Condensed";
            size = 19.5;
          };
          input = {
            # "*" = {
            #   xkb_file = toString ./keyboard-xserver/layout.xkb;
            # };
            "type:touchpad" = {
              tap = "enabled";
              natural_scroll = "enabled";
            };
          };
          gaps = {
            inner = 5;
            outer = 5;
          };
          keybindings = let
            playerctl = "${pkgs.playerctl}/bin/playerctl";
          in
            mkMerge [
              {
                "${modifier}+f" = "exec ${pkgs.foot}/bin/foot";
                "${modifier}+m" = "pkill -9 -f sway";
                "${modifier}+q" = "kill";
                "${modifier}+r" = "exec $(${pkgs.tofi}/bin/tofi-drun)";
                "${modifier}+a" = "fullscreen";
                "${modifier}+u" = "workspace back_and_forth";
                "${modifier}+v" = "floating toggle";
                "${modifier}+p" = ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png'';
                "--release Print" = ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png'';

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

                # "XF86AudioRaiseVolume" = "";
                # "XF86AudioLowerVolume" = "";
                # "XF86AudioMute" = "";
                # "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu | ${pkgs.findutils}/bin/xargs swaymsg exec --";
              }
              (mkMerge (map
                (num: let
                  strNum = builtins.toString num;
                in {
                  "${modifier}+${strNum}" = "workspace ${strNum}";
                  "${modifier}+Shift+${strNum}" = "move container to workspace ${strNum}";
                }) [1 2 3 4 5 6 7 8 9]))
            ];
        };
      };
    };
}
