{
  ssh,
  config,
  utils,
  ...
}: let
  inherit (utils) getHostname;

in {
  networking.allowedPorts.tcp."22" = ["*"];

  networking.vpnNamespace.vpn.ports = {
    tcp = ["4444->22"];
  };

  programs.ssh = {
    enable = true;

    matchBlocks = {
      mera-lan = {
        hostname = getHostname "mera.lan1";
        identitiesOnly = true;
        identityFile = [ssh.ope.ope_to_mera.private];
      };
      bara-lan = {
        hostname = getHostname "bara.lan1";
        identitiesOnly = true;
        identityFile = [ssh.ope.ope_to_bara.private];
      };
      bara-private = {
        hostname = getHostname "bara.wg_private";
        identitiesOnly = true;
        identityFile = [ssh.ope.ope_to_bara.private];
      };
      "github.com" = {
        identitiesOnly = true;
        identityFile = [ssh.ope.ope_flafydev_github.private];
      };
      "u432478.your-storagebox.de" = {
        identitiesOnly = true;
        identityFile = [ssh.ope.ope_to_sb1.private];
      };
    };

    server = {
      enable = true;
      users.${config.users.main}.keyFiles = [
        ssh.bara.bara_to_ope.public
        ssh.noro.noro_to_ope.public
      ];
    };
  };
}
