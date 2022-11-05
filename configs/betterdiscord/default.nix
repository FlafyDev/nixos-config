{
  add = _: {
    homeModules = [./hm.nix];

    overlays = _: [
      (final: prev: {
        betterdiscord-asar = prev.callPackage ./asar.nix {};
        betterdiscordPlugins = {
          hide-disabled-emojis = prev.callPackage plugins/hide-disabled-emojis.nix {};
          invisible-typing = prev.callPackage plugins/invisible-typing.nix {};
          zeres-plugin-library = prev.callPackage plugins/zeres-plugin-library.nix {};
        };
        betterdiscordThemes = {
          solana = prev.callPackage themes/solana.nix {};
          float = prev.callPackage themes/float.nix {};
          frosted-glass-green = prev.callPackage themes/frosted-glass-green {};
        };
      })
    ];
  };

  home = {pkgs, ...}: {
    programs.betterdiscord = {
      enable = true;
      plugins = with pkgs.betterdiscordPlugins; [
        hide-disabled-emojis
        invisible-typing
        zeres-plugin-library
      ];
      themes = with pkgs.betterdiscordThemes; [
        solana
        float
        frosted-glass-green
      ];
    };
  };
}
