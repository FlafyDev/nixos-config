{
  home = { pkgs, ... }: {
    home.packages = [ pkgs.discord-open-asar ];

    xdg.configFile."discord/settings.json".text = (builtins.toJSON {
      openasar = {
        setup = true;
        quickstart = true;
        noTyping = true;
        cmdPreset = "none";
        css = builtins.readFile ../../modules/betterdiscord/themes/frosted-glass-blue/FrostedGlassBlue.theme.css;
      };
      IS_MAXIMIZED = false;
      IS_MINIMIZED = false;
      WINDOW_BOUNDS = {
        x = 563;
        y = 99;
        width = 1314;
        height = 967;
      };
      trayBalloonShown = true;
      DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOURE_DOING = true;
    });
  };
}

