{
  pkgs,
  osConfig,
  lib,
  ...
}: {
  networking.vpnNamespace = {
    vpn = {
      containers = ["maneVpn"];
      vpnHost = "mane";
      vpnWgInterface = "wg_vps";
      lanForward = true;
    };
  };

  containers.maneVpn = {
    autoStart = true;

    bindMounts = {
      "/var/run/agenix/mail.flafy_dev.flafy" = {
        # hostPath = toString (pkgs.writeText "resolv.conf" ''
        #   nameserver 9.9.9.9
        #   nameserver 1.1.1.1
        # '');
        isReadOnly = true;
      };
      "/etc/resolv.conf" = {
        hostPath = toString (pkgs.writeText "resolv.conf" ''
          nameserver 9.9.9.9
          nameserver 1.1.1.1
        '');
        isReadOnly = true;
      };
    };

    config = {lib, ...}: {
      networking.enable = true;

      os.system.stateVersion = "23.11";
      os.networking.useHostResolvConf = lib.mkForce false;
    };
  };
}
