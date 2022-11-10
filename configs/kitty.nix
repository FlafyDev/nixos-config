{
  home = _: {
    programs.kitty = {
      enable = true;
      font.name = "mono";
      font.size = 16;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        allow_remote_control = true;
        window_padding_width = "16";
        background_opacity = "0.8";
        # include = "dark.conf";
        cursor_text_color = "background";
      };
    };
    # xdg.configFile."kitty/themes/dark.conf".text = ''
    #   # mydark theme
    #   background ${t."0F"}
    #   foreground ${t."00"}
    #   cursor ${t."65"}
    #   url_color ${t."65"}
    #   # black
    #   color0 ${t."0F"}
    #   color8 ${t."08"}
    #   # red
    #   color1 ${t."16"}
    #   color9 ${t."15"}
    #   # green
    #   color2 ${t."45"}
    #   color10 ${t."43"}
    #   # yellow
    #   color3 ${t."33"}
    #   color11 ${t."32"}
    #   # blue
    #   color4 ${t."66"}
    #   color12 ${t."64"}
    #   # magenta
    #   color5 ${t."76"}
    #   color13 ${t."75"}
    #   # cyan
    #   color6 ${t."55"}
    #   color14 ${t."53"}
    #   # white
    #   color7 ${t."03"}
    #   color15 ${t."00"}
    # '';
  };
}
