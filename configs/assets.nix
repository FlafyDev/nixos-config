{
  inputs.assets = {
    url = "github:flafydev/nixos-assets";
    flake = false;
  };

  add = {assets, ...}: {
    overlays = _: [
      (_final: _prev: {
        inherit assets;
      })
    ];
  };
}
