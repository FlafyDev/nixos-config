{
  home = { pkgs, ... }: {
    programs.betterdiscord = {
      enable = true;
      themes = with pkgs.betterdiscordThemes; [
        solana
        float
        frosted-glass-green
      ];
    };
  };
}
