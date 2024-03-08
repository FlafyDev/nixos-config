{
  config,
  lib,
  ...
}: let
  inherit (lib) mkAfter;
  btrfsPartition = "/dev/nvme0n1p3";
in {
  os = {
    fileSystems = {
      "/" = {
        device = "${btrfsPartition}";
        fsType = "btrfs";
        options = ["subvol=root"];
      };

      "/persist" = {
        device = "${btrfsPartition}";
        neededForBoot = true;
        fsType = "btrfs";
        options = ["subvol=persist"];
      };

      "/persist2" = {
        device = "/dev/disk/by-uuid/f48fc61e-dfc5-4797-aa73-5c873e35a1a1";
        neededForBoot = true;
        fsType = "btrfs";
        options = ["subvol=persist2"];
      };

      "/nix" = {
        device = "${btrfsPartition}";
        fsType = "btrfs";
        options = ["subvol=nix"];
      };
    };

    boot.initrd.postDeviceCommands = mkAfter ''
      mkdir /btrfs_tmp
      mount ${btrfsPartition} /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          # btrfs subvolume delete "$1"
          echo "Deleting $1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';

    environment.persistence = {
      "/persist2" = {
        hideMounts = true;
        directories = [
          # {
          #   directory = "/var/lib/acme";
          #   user = "acme";
          #   group = "acme";
          # }
          # {
          #   directory = "/var/lib/matrix-synapse";
          #   user = "matrix-synapse";
          #   group = "matrix-synapse";
          # }
          # {
          #   directory = "/var/lib/mautrix-whatsapp";
          #   user = "mautrix-whatsapp";
          #   group = "mautrix-whatsapp";
          # }
          # {
          #   directory = "/var/lib/emoji-drawing";
          #   user = "emoji-drawing";
          #   group = "emoji-drawing";
          # }
          {
            directory = "/var/vmail";
            user = "virtualMail";
            group = "virtualMail";
          }
          {
            directory = "/var/dkim";
            user = "opendkim";
            group = "opendkim";
          }
          # {
          #   directory = "/var/lib/postgresql";
          #   user = "postgresql";
          #   group = "postgresql";
          # }
        ];
      };
      "/persist" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
          {
            directory = "/var/lib/colord";
            user = "colord";
            group = "colord";
            mode = "u=rwx,g=rx,o=";
          }
        ];
        files = [
          "/etc/machine-id"
        ];

        users.${config.users.main} = {
          directories = [
            ".ssh"
            ".local/share"
            "backups"
          ];
          # directories = [
          #   {
          #     directory = ".ssh";
          #     mode = "0700";
          #     user = "server";
          #     group = "users";
          #   }
          #   {
          #     directory = ".local/share";
          #     mode = "0700";
          #     user = "server";
          #     group = "users";
          #   }
          #   {
          #     directory = "backups";
          #     mode = "0700";
          #     user = "server";
          #     group = "users";
          #   }
          # ];
        };
      };
    };
  };

  # hm.home.persistence."/persist/home/server" = {
  #   directories = [
  #     ".ssh"
  #     ".local/share"
  #   ];
  #   allowOther = true;
  # };
}
