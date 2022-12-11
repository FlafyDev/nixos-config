{
  system = {pkgs, ...}: {
    fonts.fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "AurulentSansMono"
          "JetBrainsMono"
          "FiraCode"
          "DroidSansMono"
        ];
      })
      # carlito
      source-sans
      cantarell-fonts
      dejavu_fonts
      source-code-pro # Default monospace font in 3.32
      source-sans
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];
  };
}
