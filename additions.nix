{
  overlays = { ... }: [
    (final: prev:
      let 
        inherit (prev) callPackage;
      in {
        mpvScripts = prev.mpvScripts // {
          modern-x-compact = callPackage ./modules/mpv/scripts/modern-x-compact.nix { };
        };
      }
    )
  ];

  home-modules = [
    ./modules/mpv/hm-mpv-fonts.nix
  ];
}