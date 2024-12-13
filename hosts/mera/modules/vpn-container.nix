{
  lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) mkForce;
in {
  networking.vpnNamespace = {
    vpn = {
      containers = ["maneVpn2"];
      vpnHost = "mane";
      vpnWgInterface = "wg_vps";
      lanForward = true;
    };
  };

  
  services.postgres.comb = config.containers.maneVpn2.config.cmConfig.services.postgres.comb;
  services.postgres.extraSql = config.containers.maneVpn2.config.cmConfig.services.postgres.extraSql;

  containers.maneVpn2 = {
    autoStart = true;

    bindMounts = {
      "/dev/dri".isReadOnly = false;
      "/run/opengl-driver".isReadOnly = false;
      # "/run/agenix/mail.flafy_dev.flafy" = {
      #   isReadOnly = true;
      # };
      # "/var/lib/acme" = {
      #   isReadOnly = true;
      # };
    };
    ephemeral = false;

    specialArgs = {
      inherit secrets;
    };

    config = {lib, ...}: {
      os.hardware.opengl.enable = true;
      services.postgres.enable = mkForce false;
      networking.enable = true;
      os.networking.nftables.enable = lib.mkForce true;
      os.networking.firewall.enable = lib.mkForce false;
      os.system.stateVersion = "23.11";
    };
  };
}
