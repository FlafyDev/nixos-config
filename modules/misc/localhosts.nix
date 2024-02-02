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
    os.networking.extraHosts = ''
      10.0.0.35    bara.lan1.flafy.me
      10.0.0.41    mera.lan1.flafy.me
      10.0.0.42    ope.lan1.flafy.me

      10.10.11.10  ope.wg_private.flafy.me
      10.10.11.12  bara.wg_private.flafy.me

      10.10.10.10  ope.wg_vps.flafy.me
      10.10.10.1   mane.wg_vps.flafy.me
      10.10.10.11  mera.wg_vps.flafy.me
    '';
  };
}
