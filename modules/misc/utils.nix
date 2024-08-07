{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    types
    mkOption
    ;
  cfg = config.utils;

  utils = import ../../utils {inherit lib;};

  utils' =
    utils
    // {
      flPkgs = utils.flPkgs pkgs.system;
      flPkgs' = utils.flPkgs' pkgs.system;
      flLPkgs = utils.flLPkgs pkgs.system;
      flLPkgs' = utils.flLPkgs' pkgs.system;
    }
    // cfg.extraUtils;
in {
  options.utils.enable = mkEnableOption "utils" // {default = true;};
  options.utils.extraUtils = mkOption {
    type = types.attrs;
    default = {};
    description = "Extra utils";
  };

  config = mkIf cfg.enable {
    _module.args.utils = utils';
    _module.args.upkgs = import inputs.nixpkgs-unstable {inherit (pkgs) system;};
    # os.nixpkgs.overlays = [
    #   (_final: _prev: {
    #     utils = utils';
    #   })
    # ];
  };
}
