{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  # cfg = config.environment.persistence;
in {
  # # TODO: Tunnel options
  # options.environment.persistence = mkOption {
  #   type = types.submodule (_: {
  #     options =
  #       (inputs.impermanence.nixosModules.impermanence {
  #         inherit pkgs lib;
  #         config = {};
  #       })
  #       .options
  #       .environment
  #       .persistence;
  #   });
  #   default = {};
  #   description = "Impermanence tunneled options.";
  # };

  config = {
    inputs.impermanence.url = "github:nix-community/impermanence";
    osModules = [inputs.impermanence.nixosModules.impermanence];
    hmModules = [inputs.impermanence.nixosModules.home-manager.impermanence];
  };
}
