{
  inputs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.assets;
in {
  options.assets = {
    enable = mkEnableOption "assets";
  };

  config = mkMerge [
    {
      inputs.assets = {
        url = "github:FlafyDev/assets";
      };
    }
    (
      mkIf cfg.enable {
        os.nixpkgs.overlays = [inputs.assets.overlays.default];
      }
    )
  ];
}
