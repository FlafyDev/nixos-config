{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.android;
in {
  options.android = {
    enable = mkEnableOption "android";
    dev.enable = mkEnableOption "android-dev";
  };

  config = mkMerge [
    {
    }
    (
      mkIf cfg.enable {
        # os.programs.adb.enable = true;
        os.environment.systemPackages = [
          pkgs.android-tools
        ];
      }
    )
  ];
}
