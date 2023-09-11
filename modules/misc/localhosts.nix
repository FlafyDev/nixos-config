{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.localhosts;
in {
  options.localhosts = {
    enable = mkEnableOption true;
  };

  config = mkIf cfg.enable {
    # os.networking.hosts = {
    #   "mera" = "10.0.0.41";
    # };
    os.networking.extraHosts = ''
      10.0.0.41    mera
    '';
  };
}
