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
      };
    }
    (
      mkIf cfg.enable {
        os.nixpkgs.overlays = [inputs.nur.overlays.default];
      }
    )
  ];
}
