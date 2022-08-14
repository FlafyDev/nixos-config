{
  overlays = { ... }@inputs: [
    (final: prev:
      let 
        inherit (prev) callPackage;
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
      }
    )
    inputs.npm-buildpackage.overlays.default
  ];

  home-modules = [
    ./modules/mpv/hm-mpv-fonts.nix
    ./modules/betterdiscord/hm.nix
  ];
}
