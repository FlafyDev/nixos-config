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
    "bara.home.${cfg.domains.personal}" = "10.0.0.35";
    "mera.home.${cfg.domains.personal}" = "10.0.0.41";
    "ope.home.${cfg.domains.personal}" = "10.0.0.42";

    "mane.wg_private.${cfg.domains.personal}" = "10.10.11.1";
    "ope.wg_private.${cfg.domains.personal}" = "10.10.11.10";
    "mera.wg_private.${cfg.domains.personal}" = "10.10.11.11";
    "bara.wg_private.${cfg.domains.personal}" = "10.10.11.12";
    "noro.wg_private.${cfg.domains.personal}" = "10.10.11.13";
    "glint.wg_private.${cfg.domains.personal}" = "10.10.11.14";

    "ope.wg_vps.${cfg.domains.personal}" = "10.10.10.10";
    "mane.wg_vps.${cfg.domains.personal}" = "10.10.10.1";
    "mera.wg_vps.${cfg.domains.personal}" = "10.10.10.11";
    "glint.wg_vps.${cfg.domains.personal}" = "10.10.10.14";

    "gateway.vm0.${cfg.domains.personal}" = "10.10.15.1";
    "vm.vm0.${cfg.domains.personal}" = "10.10.15.2";

    "gateway.vm1.${cfg.domains.personal}" = "10.10.15.5";
    "vm.vm1.${cfg.domains.personal}" = "10.10.15.6";

    ${cfg.domains.personal} = "64.176.169.184";
  };
in {
  options.localhosts = {
    enable = mkEnableOption true;
  };

  config = mkIf cfg.enable {
    os.networking.extraHosts = concatStringsSep "\n" (
      mapAttrsToList (name: value: "${value} ${name}") (removeAttrs hostnames [cfg.domains.personal])
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
