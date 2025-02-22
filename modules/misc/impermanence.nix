{
  inputs,
  ...
}: {
  config = {
    inputs.impermanence.url = "github:nix-community/impermanence";
    osModules = [inputs.impermanence.nixosModules.impermanence];
    hmModules = [inputs.impermanence.nixosModules.home-manager.impermanence];
  };
}
