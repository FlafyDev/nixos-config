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
      microvm.url = "path:/home/flafy/repos/astro/microvm.nix";
      microvm.inputs.nixpkgs.follows = "nixpkgs";
    };
    osModules = mkIf config.microvm.host [inputs.microvm.nixosModules.host];
  };
}

