{
  home = { pkgs, ... }: {
    programs.betterdiscord = {
      enable = true;
      plugins = with pkgs.betterdiscordPlugins; [
        hide-disabled-emojis
        invisible-typing
        zeres-plugin-library
      ];
      themes = with pkgs.betterdiscordThemes; [
        solana
        float
        frosted-glass-green
      ];
    };
  };
}
