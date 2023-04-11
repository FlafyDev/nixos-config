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
        cursor_text_color = "background";
      };
    };
  };
}
