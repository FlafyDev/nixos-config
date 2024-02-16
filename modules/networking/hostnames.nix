# TODO: move to networking
{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    concatStringsSep
    mapAttrsToList
    elem
    findFirst
    attrNames
    ;

  cfg = config.networking;

  # TODO: Make it decentralized between configurations?
  hostnames = {
    "bara.lan1.${cfg.domains.personal}" = "10.0.0.35";
    "mera.lan1.${cfg.domains.personal}" = "10.0.0.41";
    "ope.lan1.${cfg.domains.personal}" = "10.0.0.42";

    "ope.wg_private.${cfg.domains.personal}" = "10.10.11.10";
    "bara.wg_private.${cfg.domains.personal}" = "10.10.11.12";

    "ope.wg_vps.${cfg.domains.personal}" = "10.10.10.10";
    "mane.wg_vps.${cfg.domains.personal}" = "10.10.10.1";
    "mera.wg_vps.${cfg.domains.personal}" = "10.10.10.11";

    "flafy.dev" = "167.71.36.213";
    "flafy.me" = "167.71.36.213";
  };
in {
  options.localhosts = {
    enable = mkEnableOption true;
  };

  config = mkIf cfg.enable {
    os.networking.extraHosts = concatStringsSep "\n" (
      mapAttrsToList (name: value: "${value} ${name}")
      {
        "bara.lan1.${cfg.domains.personal}" = "10.0.0.35";
        "mera.lan1.${cfg.domains.personal}" = "10.0.0.41";
        "ope.lan1.${cfg.domains.personal}" = "10.0.0.42";

        "ope.wg_private.${cfg.domains.personal}" = "10.10.11.10";
        "bara.wg_private.${cfg.domains.personal}" = "10.10.11.12";

        "ope.wg_vps.${cfg.domains.personal}" = "10.10.10.10";
        "mane.wg_vps.${cfg.domains.personal}" = "10.10.10.1";
        "mera.wg_vps.${cfg.domains.personal}" = "10.10.10.11";
      }
    );

    utils.extraUtils = rec {
      resolveHostname = hostname: hostnames.${hostname} or hostnames.${getHostname hostname};
      getHostname = hostname: let
        possibleHostnames = ["${hostname}.${cfg.domains.personal}"];
      in
        findFirst (ph: elem ph (attrNames hostnames)) hostname possibleHostnames;
    };
  };
}
