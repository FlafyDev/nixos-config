{
  ssh,
  config,
  ...
}: {
  networking.allowedPorts.tcp."22" = ["*"];
  programs.ssh = {
    enable = true;
    sftp.enable = true;

    matchBlocks = {
      ope = {
        identitiesOnly = true;
        identityFile = [ssh.mera.mera_to_ope.private];
      };
      "u432478.your-storagebox.de" = {
        identitiesOnly = true;
        identityFile = [ssh.mera.mera_to_sb1.private];
      };
    };

    server = {
      enable = true;

      users.${config.users.main}.keyFiles = [
        ssh.ope.ope_to_mera.public
      ];
      users.root.keyFiles = [
        ssh.ope.ope_to_mera.public
      ];
    };
  };
}
