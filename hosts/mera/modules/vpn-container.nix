{
  pkgs,
  lib,
  osConfig,
  utils,
  secrets,
  ...
}: {
  networking.vpnNamespace = {
    vpn = {
      containers = ["maneVpn2"];
      vpnHost = "mane";
      vpnWgInterface = "wg_vps";
    };
  };

  containers.maneVpn2 = {
    autoStart = true;

    bindMounts = {
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
      networking.enable = true;
      os.networking.nftables.enable = lib.mkForce true;
      os.networking.firewall.enable = lib.mkForce false;
      os.system.stateVersion = "23.11";
    };
  };
}
