{
  home = { ... }: {
    programs.alacritty = {
      enable = true;
      
      settings = {
        window = {
      	  opacity = 0.6;
          padding = {
            x = 5;
            y = 5;
          };
        };

        selection.save_to_clipboard = true;
        
        font = {
          size = 7;
          family = "FuraCode Nerd Font Mono";
          normal = {
            style = "Regular";
          };

          bold = {
            style = "Bold";
          };
        };

        colors = {
          primary = {
            background = "0x1b2b34";
            foreground = "0xd8dee9";
          };
          normal = {
            black = "0x29414f";
            red = "0xec5f67";
            green = "0x99c794";
            yellow = "0xfac863";
            blue = "0x6699cc";
            magenta = "0xc594c5";
            cyan = "0x5fb3b3";
            white = "0x65737e";
          };
          bright = {
            black = "0x405860";
            red = "0xec5f67";
            green = "0x99c794";
            yellow = "0xfac863";
            blue = "0x6699cc";
            magenta = "0xc594c5";
            cyan = "0x5fb3b3";
            white = "0xadb5c0";
          };
        };
      };
    };
  };
}
