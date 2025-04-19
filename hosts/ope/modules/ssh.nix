{
  secrets,
  config,
  utils,
  ...
}: let
  inherit (utils) getHostname;

in {
  # networking.allowedPorts.tcp."22" = ["*"];

  # networking.vpnNamespace.vpn.ports = {
  #   tcp = ["4444->22"];
  # };

  programs.ssh = {
    enable = true;

    matchBlocks = {
      mera-lan = {
        hostname = getHostname "mera.home";
        identitiesOnly = true;
        identityFile = [secrets.ssh-keys.ope.ope_to_mera.private];
      };
      bara-lan = {
        hostname = getHostname "bara.home";
        identitiesOnly = true;
        identityFile = [secrets.ssh-keys.ope.ope_to_bara.private];
      };
      bara-private = {
        hostname = getHostname "bara.wg_private";
        identitiesOnly = true;
        identityFile = [secrets.ssh-keys.ope.ope_to_bara.private];
      };
      "github.com" = {
        identitiesOnly = true;
        identityFile = [secrets.ssh-keys.ope.ope_flafydev_github.private];
      };
      "u432478.your-storagebox.de" = {
        identitiesOnly = true;
        identityFile = [secrets.ssh-keys.ope.ope_to_sb1.private];
      };
    };

    server = {
      enable = true;
      users.${config.users.main}.keyFiles = [
        secrets.ssh-keys.bara.bara_to_ope.public.filePath
        secrets.ssh-keys.noro.noro_to_ope.public.filePath
        secrets.ssh-keys.glint.glint_to_ope.public.filePath
      ];
    };
  };
}
