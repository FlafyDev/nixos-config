# TODO: move to networking
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.localhosts;

  hostnames = {
    "bara.lan1.flafy.me" = "10.0.0.35";
    "mera.lan1.flafy.me" = "10.0.0.41";
    "ope.lan1.flafy.me" = "10.0.0.42";

    "ope.wg_private.flafy.me" = "10.10.11.10";
    "bara.wg_private.flafy.me" = "10.10.11.12";

    "ope.wg_vps.flafy.me" = "10.10.10.10";
    "mane.wg_vps.flafy.me" = "10.10.10.1";
    "mera.wg_vps.flafy.me" = "10.10.10.11";

    "flafy.me" = "167.71.36.213";
  };
in {
  options.localhosts = {
    enable = mkEnableOption true;
  };

  config = mkIf cfg.enable {
    # TODO: Autogenerate this
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

    _module.args.resolveHostname = host: hostnames.${host} or host;
  };
}
