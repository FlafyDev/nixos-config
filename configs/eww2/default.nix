{
  home = { pkgs, ... }: with pkgs; let 
    getWorkspaces = writeShellScript "getWorkspaces" ''
      # 
      # activeSymbol="◆"
      # occupiedSymbol="◈"
      # freeSymbol="◇"
      # symbols=( )

      # hyprctl workspaces -j | jq ".[] | .id" | while read id; do
      #   echo $symbols[$id]=$occupidSymbol;

      # done

      # $symbols[$(hyprctl monitors -j | jq ".[0].activeWorkspace.id")]=$activeSymbol

      # # getWorkspaceSymbol() {
      # #   workspace=$(hyprctl workspaces -j | ${pkgs.jq}/bin/jq ".[] | select(.id==$number)")
      # #   activeWorkspaceId=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq '.workspace.id')

      # #   if [ "$activeWorkspaceId" == "$number" ]; then
      # #     echo "◆"
      # #   elif [ "$workspace" ]; then
      # #     echo "◈"
      # #   else 
      # #     echo "◇"
      # #   fi
      # # }

      # # workspaces() {
      # #   buffered=""

      # #   for number in {1..9}; do
      # #     symbol=$(getWorkspaceSymbol);
      # #     class="unselected";
      # #     if [ "$symbol" == "◆" ]; then
      # #       class="selected";
      # #     fi

      # #     buffered+="(button :class	\"$class\" \"$symbol\")"
      # #   done

      # #   echo "(box	:class \"ws\" :orientation \"v\"	:halign \"start\"	:valign \"center\"	 :space-evenly \"false\" :spacing \"-5\" $buffered)"
      # # }

      # onEvent() {

      # }

      # workspaces
      # ${pkgs.socat}/bin/socat -u UNIX-CONNECT:/tmp/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/.socket2.sock - | while read -r; do
      #   workspaces
      # done
    '';
    # getWorkspaces = writeShellScript "getWorkspaces" ''
    #   ic=(1 2 3 4 5 6 7 8 9)

    #   #initial check for occupied workspaces
    #   for num in $(hyprctl workspaces | grep ID | awk '{print $3}'); do 
    #     export o"$num"="$num"
    #   done
    #    
    #   #initial check for focused workspace
    #   for num in $(hyprctl monitors | grep -B 4 "focused: yes" | awk 'NR==1{print $3}'); do 
    #     export f"$num"="$num"
    #     export fnum=f"$num"
    #   done

    #   workspaces() {
    #     if [[ ''${1:0:9} == "workspace" ]]; then #set focused workspace
    #       unset -v "$fnum" 
    #       num=''${1:11}
    #       export f"$num"="$num"
    #       export fnum=f"$num"

    #     elif [[ ''${1:0:10} == "focusedmon" ]]; then #set focused workspace
    #       unset -v "$fnum"
    #       num=''${1##*,}
    #       export f"$num"="$num"
    #       export fnum=f"$num"

    #     elif [[ ''${1:0:15} == "createworkspace" ]]; then #set Occupied workspace
    #       num=''${1:17}
    #       export o"$num"="$num"
    #       export onum=o"$num"

    #     elif [[ ''${1:0:16} == "destroyworkspace" ]]; then #unset unoccupied workspace
    #       num=''${1:18}
    #       unset -v o"$num"
    #     fi
    #   }
    #   module() {
    #     #output eww widget
    #     echo "(eventbox :onscroll \"echo {} | sed -e 's/up/-1/g' -e 's/down/+1/g' | xargs hyprctl dispatch workspace\" \
    #             (box :class \"ws\" :orientation \"v\"	:halign \"start\"	:valign \"center\"	 :space-evenly \"false\" :spacing \"-5\"  	\
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 1\'\" :onrightclick \"hyprctl dispatch workspace 1 && $HOME/.config/hypr/default_app\" :class \"0$o1$f1\" \"''${ic[1]}\") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 2\'\" :onrightclick \"hyprctl dispatch workspace 2 && $HOME/.config/hypr/default_app\" :class \"0$o2$f2\" \"''${ic[2]}\") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 3\'\" :onrightclick \"hyprctl dispatch workspace 3 && $HOME/.config/hypr/default_app\" :class \"0$o3$f3\" \"''${ic[3]}\") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 4\'\" :onrightclick \"hyprctl dispatch workspace 4 && $HOME/.config/hypr/default_app\" :class \"0$o4$f4\" \"''${ic[4]}\") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 5\'\" :onrightclick \"hyprctl dispatch workspace 5 && $HOME/.config/hypr/default_app\" :class \"0$o5$f5\" \"''${ic[5]}\") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 6\'\" :onrightclick \"hyprctl dispatch workspace 6 && $HOME/.config/hypr/default_app\" :class \"0$o6$f6\" \"''${ic[6]}\") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 7\'\" :onrightclick \"hyprctl dispatch workspace 7 && $HOME/.config/hypr/default_app\" :class \"0$o7$f7\" \"''${ic[7]} \") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 8\'\" :onrightclick \"hyprctl dispatch workspace 8 && $HOME/.config/hypr/default_app\" :class \"0$o8$f8\" \"''${ic[8]} \") \
    #               (button :onclick \"hyprctl dispatch exec \'~/.config/hypr/workspace 9\'\" :onrightclick \"hyprctl dispatch workspace 9 && $HOME/.config/hypr/default_app\" :class \"0$o9$f9\" \"''${ic[9]}\") \
    #             )\
    #           )"
    #   }

    #   module
    #   socat -u UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | while read -r event; do 
    #     workspaces "$event"
    #     module
    #   done 
    # '';
  in {
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

