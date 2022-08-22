{
  home = { pkgs, ... }: with pkgs; {
    programs.customEww = {
      enable = true;
      package = pkgs.eww-wayland;
      scss = ./eww.scss;
      yuck = writeText "eww.yuck" ''
        ;; BAR
        (defwindow bar
          :geometry (geometry :height "100%" :anchor "left center")
          :monitor 0 
          :exclusive true
          :focusable false
          :stacking "fg"
          (bar))

        (defwidget bar []
          (box :class "eww-bar" :orientation "v"
            ;; (top)
            (center)
            (bottom)))

        ;; (defwidget top []
        ;;   (box :orientation "v" :halign "center" :valign "start" :space-evenly "true" 
        ;;     (language)))

        (defwidget center []
          (box :orientation "v" :halign "center" :valign "center" :space-evenly "false"
            (workspaces)))

        (defwidget bottom []
          (box :orientation "v" :halign "center" :valign "end" :space-evenly "false" :spacing "7"
            (time)))

        ;; BAR WIDGETS
        (defwidget workspaces []
          (literal :content workspace))

        (deflisten workspace "${pkgs.python310}/bin/python ${./scripts/getWorkspaces.py}")

        (defwidget time []
          (box :class "time" :tooltip "It's ''${fullDate}" :orientation "v" :halign "center" :space-evenly "false"
            (button :class "hour" hour)
            (button :class "min" min)
            (button :class "month" monthDay)))
        (defpoll hour :interval "1s" "date '+%H'")
        (defpoll min :interval "1s" "date '+%M'")
        (defpoll monthDay :interval "1s" "date '+%d.%m'")
        (defpoll fullDate :interval "1s" "date '+%A %B %T'")
      '';
    };
  };
}

