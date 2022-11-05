{
  inputs.assets = {
    url = "github:flafydev/nixos-assets";
    flake = false;
  };

  add = {assets, ...}: {
    overlays = _: [
      (final: prev: {
        inherit assets;
      })
    ];
  };
}
