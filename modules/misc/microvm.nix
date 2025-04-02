{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkIf;
in {
  options = {
    microvm = {
      host = mkOption {
        default = true;
        type = types.bool;
        description = "microvm host";
      };
    };
  };
  config = {
    inputs = {
      microvm.url = "github:FlafyDev/microvm.nix/flafy-main";
      microvm.inputs.nixpkgs.follows = "nixpkgs";
    };
    osModules = mkIf config.microvm.host [inputs.microvm.nixosModules.host];
  };
}
