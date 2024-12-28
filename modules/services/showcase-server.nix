{inputs, ...}: {
  osModules = [inputs.showcase.nixosModules.default];

  inputs = {
    showcase.url = "git+file:///home/flafy/repos/flafydev/showcase2";
  };
}
