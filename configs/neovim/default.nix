{
  system = { pkgs, ... }: {
    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
  };

  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      # telescope-nvim
      ripgrep
      fd
    ];

    programs.neovim = {
      enable = true;

      plugins = import ./plugins pkgs;
    };
  };
  
}