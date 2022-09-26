{ wayland }: {
  system = { pkgs, ... }: {
    environment.sessionVariables = {
       DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    };
  };

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
          "browser.fullscreen.autohide" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.force-enabled" = true;
          "general.smoothScroll.msdPhysics.enabled" = true;
          "layout.frame_rate" = 120;
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
