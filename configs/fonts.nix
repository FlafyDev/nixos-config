let
  buildFonts = pkgs:
    with pkgs; [
      (nerdfonts.override {
        fonts = [
          # "AurulentSansMono"
          # "Iosevka"
          # "JetBrainsMono"
          "FiraCode"
          # "DroidSansMono"
        ];
      })
      carlito
      corefonts
      source-sans
      # cantarell-fonts
      dejavu_fonts
      source-code-pro # Default monospace font in 3.32
      source-sans
      # noto-fonts
      # noto-fonts-cjk
      # noto-fonts-emoji
      # liberation_ttf
      # fira-code
      # fira-code-symbols
      # mplus-outline-fonts.githubRelease
      # # dina-font
      # proggyfonts
      # material-icons
      # material-design-icons
      roboto
      # work-sans
      # comic-neue
      # twemoji-color-font
      # comfortaa
      # inter
      # lato
      # jost
      # lexend
      # iosevka-bin
      # jetbrains-mono
    ];
in {
  system = {pkgs, ...}: {
    fonts.fonts = buildFonts pkgs;
  };

  home = {pkgs, ...}: {
    fonts = {
      fontconfig = {
        enable = true;
      };
    };
    home.packages = buildFonts pkgs;
  };
}
