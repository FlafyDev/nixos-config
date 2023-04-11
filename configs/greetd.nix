{
  system = {pkgs, username, ...}: {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd hyprland";
          user = username;
        };
      };
    };
  };
}
