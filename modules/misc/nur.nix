{
  inputs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.nur;
in {
  options.nur = {
    enable = mkEnableOption "NUR";
  };

  config = mkIf cfg.enable {
    inputs.nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.overlays = [inputs.nur.overlay];
  };
}
