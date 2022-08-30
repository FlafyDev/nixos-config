{ wayland }: {
  home = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      package = if wayland then pkgs.wrapFirefox pkgs.firefox-unwrapped {
        forceWayland = true;
        extraPolicies = {
          ExtensionSettings = {};
        };
      } else pkgs.firefox;
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        settings = {
          # "layout.css.devPixelsPerPx" = "1.2";
        };
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        vimium
        ublock-origin
        bitwarden
      ];
    };
  };
}
