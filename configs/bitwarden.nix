{
  home = { pkgs, ... }: {
    home.packages = with pkgs; [
      xdotool
      rbw
      pinentry
    ];
  };
}
