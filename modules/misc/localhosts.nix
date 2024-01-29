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
      10.0.0.41    mera.lan1.flafy.me
      10.0.0.42    ope.lan1.flafy.me
      127.0.0.1    justatest.me
      127.0.0.1    emoji.justatest.me
    '';
  };
}
