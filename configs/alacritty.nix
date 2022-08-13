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
          normal = {
            black = "#000000";
            red = "#a60001";
            green = "#00bb00";
            yellow = "#fecd22";
            blue = "#3a9bdb";
            magenta = "#bb00bb";
            cyan = "#00bbbb";
            white = "#bbbbbb";
          };
        };
      };
    };
  };
}
