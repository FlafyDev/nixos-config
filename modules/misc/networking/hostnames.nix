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
    "bara.home.${cfg.domains.personal}" = "10.0.0.${machineIDs.bara}";
    "mera.home.${cfg.domains.personal}" = "10.0.0.${machineIDs.mera}";
    "ope.home.${cfg.domains.personal}" = "10.0.0.${machineIDs.ope}";

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
    "ito.wg_vps.${cfg.domains.personal}" = "10.10.10.15";

    "gateway.vm0.${cfg.domains.personal}" = "10.10.15.1";
    "vm.vm0.${cfg.domains.personal}" = "10.10.15.2";

    "gateway.vm1.${cfg.domains.personal}" = "10.10.15.5";
    "vm.vm1.${cfg.domains.personal}" = "10.10.15.6";

    ${cfg.domains.personal} = "64.176.169.184";
  };
  machineIDs = { 
    bara = "35";
    mera = "41";
    ope = "42";
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
      gpIP = gpID:
        gpIPex config.os.networking.hostName gpID;
      gpIPex = machineName: gpID: let 
        machineID = machineIDs.${machineName};
        prefix = "10.6.${machineID}";
        subnet = gpID * 4;
      in {
        host = "${prefix}.${toString (subnet + 1)}";
        guest = "${prefix}.${toString (subnet + 2)}";
      };
      getHostname = hostname: let
        possibleHostnames = ["${hostname}.${cfg.domains.personal}"];
      in
        findFirst (ph: elem ph (attrNames hostnames)) hostname possibleHostnames;
    };
  };
}
