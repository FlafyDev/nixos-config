{
  inputs = {
    nur = {
      url = "github:nix-community/NUR";
    };
  };

  add = {nur, ...}: {
    overlays = _: [nur.overlay];
  };
}
