let 
  overlays = { ... }@inputs: [
    inputs.nur.overlay 
    (final: prev:
      let 
        inherit (prev) callPackage fetchFromGitHub;
      in {
        betterdiscord-asar = callPackage ./modules/betterdiscord/asar.nix { };
        mpvScripts = prev.mpvScripts // {
          modern-x-compact = callPackage ./modules/mpv/scripts/modern-x-compact.nix { };
        };
        betterdiscordThemes = {
          solana = callPackage ./modules/betterdiscord/themes/solana.nix { };
          float = callPackage ./modules/betterdiscord/themes/float.nix { };
          frosted-glass-green = callPackage ./modules/betterdiscord/themes/frosted-glass-green { };
        };
        rofiThemes = {
          sideNavy = callPackage (import ./utils/mk-rofi-theme.nix {
            type = 3;
            style = 9;
            colorScheme = "navy";
          }) { };
        };
        i3-alternating-layout = callPackage ./modules/i3-alternating-layout.nix { };
        mpvpaper = callPackage ./modules/mpvpaper.nix { };
        mpv-unwrapped-stable = prev.mpv-unwrapped;
        mpv-unwrapped = prev.mpv-unwrapped.overrideAttrs (prev: {
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
    inputs.npm-buildpackage.overlays.default
  ];
in {
  modules = { ... }@inputs: [
    inputs.hyprland.nixosModules.default
    ({ ... }: {
      nixpkgs.overlays = overlays inputs; 
    })
  ];

  homeModules = { ... }@inputs: [
    inputs.hyprland.homeManagerModules.default
    ./modules/mpv/hm-mpv-fonts.nix
    ./modules/betterdiscord/hm.nix
    ./modules/hm-custom-eww.nix
  ];
}
