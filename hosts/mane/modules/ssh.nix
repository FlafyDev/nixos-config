{
  secrets,
  config,
  ...
}: {
  # networking.allowedPorts.tcp."22" = ["*"];
  programs.ssh = {
    enable = true;
    sftp.enable = true;
    server = {
      enable = true;
      users.${config.users.main}.keyFiles = [
        secrets.ssh-keys.ope.ope_to_mane.public.filePath
      ];
      users.root.keyFiles = [
        secrets.ssh-keys.ope.ope_to_mane.public.filePath
      ];
    };
  };
}
