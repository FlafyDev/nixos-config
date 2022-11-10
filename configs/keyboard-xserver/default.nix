{
  system = {pkgs, ...}: let
    compiledLayout = pkgs.runCommand "keyboard-layout" {} ''
      ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${./layout.xkb} $out
    '';
  in {
    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xset}/bin/xset r rate 200 40
      ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY
    '';
  };
}
