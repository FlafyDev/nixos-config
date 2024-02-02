{
  ssh,
  config,
  ...
}: {
  networking.allowedPorts.tcp."22" = ["*"];
  programs.ssh = {
    enable = true;
    sftp.enable = true;
    server = {
      enable = true;
      users.${config.users.main}.keyFiles = [
        ssh.ope.ope_to_mane.public
      ];
      users.root.keyFiles = [
        ssh.ope.ope_to_mane.public
      ];
    };
  };
}
