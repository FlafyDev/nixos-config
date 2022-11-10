{
  home = {pkgs, ...}: {
    home.packages = with pkgs; [
      rbw
      pinentry
    ];
  };
}
