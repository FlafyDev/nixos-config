username: {
  system = {pkgs, ...}: {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd hyprland";
          # command = "${pkgs.hyprland-wrapped}/bin/hyprland";
          # if config.specialisation != {}
          # then "${pkgs.hyprland-wrapped}/bin/hyprland"
          # else "WLR_DRM_DEVICES=/dev/dri/card0 ${pkgs.hyprland-wrapped}/bin/hyprland";
          user = username;
        };
        # initial_session = {
        #   command = "${pkgs.hyprland-wrapped}/bin/hyprland";
        #   user = username;
        # };
      };
    };
  };
}
