let
  overlays = inputs: [
    inputs.nur.overlay
    inputs.npm-buildpackage.overlays.default
    # inputs.hyprland.overlays.default
    inputs.lang-to-docx.overlays.default
    inputs.tofi-rbw.overlays.default
    inputs.guifetch.overlays.default
    inputs.listen-blue.overlays.default
    inputs.nix-alien.overlays.default
    inputs.cp-maps.overlays.default
    (
      final: prev: let
        inherit (prev) callPackage fetchFromGitHub;
      in {
        inherit (inputs) qutebrowser-base16;
        patchDesktop = pkg: appName: from: to:
          final.hiPrio (final.runCommand "$patched-desktop-entry-for-${appName}" {} ''
            ${final.coreutils}/bin/mkdir -p $out/share/applications
            ${final.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
          '');
        writers =
          prev.writers
          // {
            writePython310Bin = name: prev.writers.makePythonWriter prev.python310 prev.python310Packages "/bin/${name}";
          };
        betterdiscord-asar = callPackage ./modules/betterdiscord/asar.nix {};
        mpvScripts =
          prev.mpvScripts
          // {
            modern-x-compact = callPackage ./modules/mpv/scripts/modern-x-compact.nix {};
          };
        betterdiscordPlugins = {
          hide-disabled-emojis = callPackage ./modules/betterdiscord/plugins/hide-disabled-emojis.nix {};
          invisible-typing = callPackage ./modules/betterdiscord/plugins/invisible-typing.nix {};
          zeres-plugin-library = callPackage ./modules/betterdiscord/plugins/zeres-plugin-library.nix {};
        };
        betterdiscordThemes = {
          solana = callPackage ./modules/betterdiscord/themes/solana.nix {};
          float = callPackage ./modules/betterdiscord/themes/float.nix {};
          frosted-glass-green = callPackage ./modules/betterdiscord/themes/frosted-glass-green {};
        };
        rofiThemes = {
          sideNavy =
            callPackage
            (import ./utils/mk-rofi-theme.nix {
              type = 3;
              style = 9;
              colorScheme = "navy";
            })
            {};
        };
        webcord = inputs.webcord.packages.${prev.system}.default;
        discord-open-asar = prev.discord.override {withOpenASAR = true;};

        bspwm-rounded = prev.bspwm.overrideAttrs (_: {
          src = inputs.bspwm-rounded;
        });

        # hyprland-wrapped = prev.writeShellScriptBin "hyprland" ''
        #   export LIBVA_DRIVER_NAME="nvidia";
        #   export GBM_BACKEND="nvidia-drm";
        #   export __GLX_VENDOR_LIBRARY_NAME="nvidia";
        #   # export WLR_DRM_DEVICES=/dev/dri/card0
        #
        #   export _JAVA_AWT_WM_NONREPARENTING=1;
        #   export XCURSOR_SIZE=1;
        #   # export WLR_NO_HARDWARE_CURSORS="1";
        #   export CLUTTER_BACKEND="wayland";
        #   export XDG_SESSION_TYPE="wayland";
        #   export QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
        #   export MOZ_ENABLE_WAYLAND="1";
        #   export WLR_BACKEND="vulkan";
        #   export QT_QPA_PLATFORM="wayland";
        #   export GDK_BACKEND="wayland";
        #   export TERM="foot";
        #   export NIXOS_OZONE_WL="1";
        #   ${inputs.hyprland.packages.${prev.system}.default}/bin/Hyprland "$@"
        # '';

        sway-borders = let
          sway-unwrapped = prev.sway-unwrapped.overrideAttrs (_: {
            src = inputs.sway-borders;
          });
        in
          prev.sway.override
          {
            inherit sway-unwrapped;
          };

        firefox-addons = {
          sponsor-block = prev.fetchFirefoxAddon {
            name = "sponsor-block";
            src = inputs.firefox-sponsor-block;
            # url =
            #   "https://addons.mozilla.org/firefox/downloads/file/4011816/sponsorblock-5.0.7.xpi";
            # sha256 = "/XqkOnjPiHJyyNJt6cJnqbiWBbQRj5zh/XwbdfYx6uQ=";
          };
          vimium = prev.fetchFirefoxAddon {
            name = "vimium-ff";
            src = inputs.firefox-vimium-ff;
            # url =
            #   "https://addons.mozilla.org/firefox/downloads/file/3898202/vimium_ff-1.67.1.xpi";
            # sha256 = "EnQIAnSOer/48TAUyEXbGCtSZvKA4vniL64K+CeJ/m0=";
          };
          ublock-origin = prev.fetchFirefoxAddon {
            name = "ublock";
            src = inputs.firefox-ublock-origin;
            # url =
            #   "https://addons.mozilla.org/firefox/downloads/file/4003969/ublock_origin-1.44.4.xpi";
            # sha256 = "C+VQyaJ8BA0ErXGVTdnppJZ6J9SP+izf6RFxdS4VJoU=";
          };
          bitwarden = prev.fetchFirefoxAddon {
            name = "bitwarden";
            src = inputs.firefox-bitwarden;
          };
          stylus = prev.fetchFirefoxAddon {
            name = "stylus";
            src = inputs.firefox-stylus;
          };
        };

        neovide = prev.callPackage ./modules/neovide.nix {};

        # neovide = (prev.callPackage ./modules/neovide.nix {}).overrideAttrs (prev: rec {
        #   src = inputs.neovide;
        #   cargoDeps = prev.cargoDeps.overrideAttrs (_: {
        #     inherit src;
        #     name = "neovide-vendor.tar.gz";
        #     outputHash = "sha256-6yEu/BySDBlmCfBGxz1ozprbE60ninyQkKqBVo0Uo6k=";
        #   });
        # });

        # mpv-with-vapoursynth = prev.wrapMpv final.mpv-unwrapped {
        #   # extraMakeWrapperArgs = [
        #   #   "--prefix" "LD_LIBRARY_PATH" ":" "${prev.vapoursynth-mvtools}/lib/vapoursynth"
        #   # ];
        # };

        discord-electron-openasar =
          prev.callPackage
          ./modules/discord.nix
          {
            inherit (prev.discord) src version pname;
            openasar = prev.callPackage "${inputs.nixpkgs}/pkgs/applications/networking/instant-messengers/discord/openasar.nix" {};
            binaryName = "Discord";
            desktopName = "Discord";

            webRTC = true;
            enableVulkan = true;

            extraOptions = [
              "--disable-gpu-memory-buffer-video-frames"
              "--enable-accelerated-mjpeg-decode"
              "--enable-accelerated-video"
              "--enable-gpu-rasterization"
              "--enable-native-gpu-memory-buffers"
              "--enable-zero-copy"
              "--ignore-gpu-blocklist"
            ];
          };
        vimPlugins =
          prev.vimPlugins
          // (
            let
              inherit (prev.vimUtils) buildVimPluginFrom2Nix;
            in {
              custom-theme-nvim = buildVimPluginFrom2Nix {
                pname = "custom-theme.nvim";
                version = "git";
                src = inputs.custom-theme-nvim;
              };
              bufresize-nvim = buildVimPluginFrom2Nix {
                pname = "bufresize.nvim";
                version = "2022-09-02";
                src = inputs.bufresize-nvim;
              };
              flutter-tools-nvim = buildVimPluginFrom2Nix {
                pname = "flutter-tools.nvim";
                version = "2022-08-26";
                src = inputs.flutter-tools-nvim;
                # src = fetchFromGitHub {
                #   owner = "FlafyDev";
                #   repo = "flutter-tools.nvim";
                #   rev = "1ea7eca2c88fd56bc64eaa71676b9290932ef2d4";
                #   sha256 = "d/rbkNLVe42dSdb68AizGbZb7mfPscp6V2NI6yEqLe8=";
                # };
                meta.homepage = "https://github.com/FlafyDev/flutter-tools.nvim/";
              };
              yuck-vim = buildVimPluginFrom2Nix {
                pname = "yuck-vim";
                version = "2022-06-20";
                src = inputs.yuck-vim;
                meta.homepage = "https://github.com/elkowar/yuck.vim";
              };
            }
          );
        i3-alternating-layout =
          callPackage
          ./modules/i3-alternating-layout.nix
          {};
        xborder =
          callPackage
          ./modules/xborder.nix
          {};
        mpvpaper =
          callPackage
          ./modules/mpvpaper.nix
          {};
        mpv-unwrapped-stable = prev.mpv-unwrapped;
        svpflow =
          callPackage
          ./modules/svpflow.nix
          {};
        mpv-unwrapped =
          prev.mpv-unwrapped.overrideAttrs
          (_: {
            version = "2022-08-21";
            src = fetchFromGitHub {
              owner = "mpv-player";
              repo = "mpv";
              rev = "37aea112c15958052bcc6d0582593edf3bfead8f";
              sha256 = "tlti/usreOBYWgTMDNsdKOL4Xa3TPeqcx9hUkLdYmN0=";
            };
          });
      }
    )
  ];
in {
  modules = inputs: [
    # inputs.hyprland.nixosModules.default
    (_: {
      nixpkgs.overlays = overlays inputs;
    })
  ];

  homeModules = inputs: [
    # inputs.hyprland.homeManagerModules.default
    # inputs.discocss.hmModule
    ./modules/mpv/hm-mpv-fonts.nix
    ./modules/betterdiscord/hm.nix
    ./modules/hm-custom-eww.nix
  ];
}
