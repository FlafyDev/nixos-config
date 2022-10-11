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
      profiles.default = let 
        startpage = pkgs.substituteAll { src = ./startpage.html; background = ../../assets/forest.jpg; };
        userChrome = pkgs.substituteAll { src = ./userChrome.css; background = ../../assets/forest.jpg; };
      in {
        id = 0;
        name = "Default";
        isDefault = true;
        userChrome = builtins.readFile userChrome;
        settings = {
          "browser.fullscreen.autohide" = false;
          "media.ffmpeg.vaapi.enabled" = true;
          "media.hardware-video-decoding.force-enabled" = true;
          "general.smoothScroll.msdPhysics.enabled" = true;
          "layout.frame_rate" = 60;
          # "layout.css.devPixelsPerPx" = "1.2";
          "layout.css.devPixelsPerPx" = "-1.0";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.startup.homepage" = "file://${startpage}";
          "browser.newtabpage.enabled" = false;
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
