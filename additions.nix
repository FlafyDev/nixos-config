let
  overlays = inputs: [
    inputs.nur.overlay
    inputs.nix-alien.overlays.default
    inputs.cp-maps.overlays.default
    (
      final: prev: let
        inherit (prev) callPackage;
      in {
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
        webcord = inputs.webcord.packages.${prev.system}.default;

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

        # mpv-unwrapped-stable = prev.mpv-unwrapped;
        # mpv-unwrapped =
        #   prev.mpv-unwrapped.overrideAttrs
        #   (_: {
        #     version = "2022-08-21";
        #     src = fetchFromGitHub {
        #       owner = "mpv-player";
        #       repo = "mpv";
        #       rev = "37aea112c15958052bcc6d0582593edf3bfead8f";
        #       sha256 = "tlti/usreOBYWgTMDNsdKOL4Xa3TPeqcx9hUkLdYmN0=";
        #     };
        #   });
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
  ];
}
