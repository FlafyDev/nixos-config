{inputs, ...}: {
  osModules = [inputs.showcase.nixosModules.default];

  inputs = {
    showcase.url = "github:flafydev/showcase";
  };
}
