{
  home = { pkgs, ... }: {
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        forceWayland = true;
        extraPolicies = {
          ExtensionSettings = {};
        };
      };
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        settings = {
          # "layout.css.devPixelsPerPx" = 130"1.2";
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
