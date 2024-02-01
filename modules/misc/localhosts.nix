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
      10.0.0.35    bara.lan1.flafy.me
      10.0.0.41    mera.lan1.flafy.me
      10.0.0.42    ope.lan1.flafy.me
      10.10.11.10  ope.private.flafy.me
      10.10.11.12  bara.private.flafy.me
    '';
  };
}
