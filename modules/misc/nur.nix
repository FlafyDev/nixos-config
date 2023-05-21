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

  config = mkMerge [
    {
      inputs.nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    }
    (
      mkIf cfg.enable {
        nixpkgs.overlays = [inputs.nur.overlay];
      }
    )
  ];
}
