{
  system = { nur, ... }: [
    nur.overlay
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

  home = { ... }: {
    imports = [
      ./modules/mpv/hm-mpv-fonts.nix
    ];
  };
}