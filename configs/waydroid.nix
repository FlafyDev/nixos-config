{
  add = _: {
    overlays = _: [
      (final: prev: {
        waydroid = prev.waydroid.overrideAttrs (old: {
          src = prev.fetchFromGitHub {
            owner = "waydroid"; 
            repo = "waydroid";
            rev = "38aebb39e4e6fb6c9766d4cd3a11f74d42c9d683";
            sha256 = "sha256-8ykFedM+v3Ju49mJdX+W0G+4rTUfuOalt4bO7PwLkL0=";
          };
        });
      })
    ];
  };

  system = _: {
    virtualisation = {
      waydroid.enable = true;
      lxd.enable = true;
    };
  };
}
