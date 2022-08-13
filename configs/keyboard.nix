{
  system = { pkgs, ... }: {
    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xset}/bin/xset r rate 200 40
      ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option caps:escape
    '';
  };
}
