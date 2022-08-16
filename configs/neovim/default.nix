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

    imports = [
      ./plugins
    ];

    programs.neovim = {
      enable = true;

      extraConfig = ''
        lua<<EOF
          ${builtins.readFile ./init.lua}
        EOF
      '';

      extraPackages = with pkgs; [
        rnix-lsp
      ];
    };
  };
  
}
