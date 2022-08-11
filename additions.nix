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
      }
    )
    inputs.npm-buildpackage.overlays.default
  ];

  home-modules = [
    ./modules/mpv/hm-mpv-fonts.nix
    ./modules/betterdiscord/hm.nix
  ];
}