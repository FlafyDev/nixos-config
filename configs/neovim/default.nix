{
  system = { pkgs, ... }: {
    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    ];
  };

  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      ripgrep
      fd
    ];

    programs.neovim = {
      enable = true;

      plugins = import ./plugins pkgs;
      extraConfig = ''
        lua<<EOF
          ${builtins.readFile ./init.lua}
        EOF
      '';
    };
  };
  
}
