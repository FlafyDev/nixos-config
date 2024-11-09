{pkgs, ssh, lib, secrets, ...}: let
  pathsToBackup = [
    "/persist2/var/lib/nextcloud-data/data/"
  ];

  command = ''${pkgs.restic}/bin/restic backup /persist2/var/lib/nextcloud-data/data/ '' +
    ''-o sftp.args="-i ${ssh.mera.mera_to_sb1.private} -o IdentitiesOnly=yes -o StrictHostKeyChecking=no" '' +
    ''--password-command "cat ${secrets.restic-sb1-backups-password}" --repo sftp:u432478@u432478.your-storagebox.de:/home/backups'';
in {
  containers.sb1Backup = {
    autoStart = true;

    bindMounts = lib.foldl' (acc: path: acc // {
        "${path}" = {
          isReadOnly = true;
        };
      }) {} (pathsToBackup ++ [
        ssh.mera.mera_to_sb1.private
        secrets.restic-sb1-backups-password
      ]);
    ephemeral = false;

    config = {
      networking.enable = true;
      os = {
        systemd.timers.backupToSB1 = {
          description = "Timer for backupToSB1Timer, runs every 60 minutes after previous run finishes";
          timerConfig = {
            OnBootSec="10min";
            OnUnitActiveSec = "60min";
            Persistent = true;
          };
          wantedBy = [ "timers.target" ];
        };
        systemd.services.backupToSB1 = {
          description = "Backup data to sb1";
          serviceConfig = {
            Type = "simple";

            ExecStart = command;
            Environment = [
              "PATH=${lib.makeBinPath (with pkgs; [
                openssh
                coreutils
              ])}"
              "HOME=/root"
            ];

            DynamicUser = false;
            ReadOnlyPaths = pathsToBackup ++ [
              ssh.mera.mera_to_sb1.private
              secrets.restic-sb1-backups-password
            ];
          };
        };
        system.stateVersion = "23.11";
      };
    };
  };
}
