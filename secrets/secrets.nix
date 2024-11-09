# Not imported by nix. Used by agenix's cli too.
let
  publicKeys = {
    ope = {
      user = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrGKIwxotjcyJh4nmp7ZqZVpGtQncoxG7ypTHCoQa1y685OD3F8g4ubBDwuigy7sfshXAA4eenxo3qL6WbNfJCJ3WTP0/6o3AxKTDj3cKt2+bbpOR1hPHuPb3Qn21ot6M+fvDqKZmkpWBls5Cze2U6+7WG5aO/rxXeC8sw4fEK12fhWXwysX6NUIoKh61s51IIr/L2pbhtE1C0yD7I6x3jjtrAxYS1+oBboTI5lSd87LZJTfAsQWmJc0hcEi44AEsgCfbOd2+l4fS3PGB7gKV1pNvKW2bCurqYLfZFNLMyMa8xA4H2iMOJoBJ8W810bFpWYuEGSWMFwCB+DunHYGRtgAnTqLbhx+//2Snz5QSDpt34WrFVOLHuxhVaSAD7inQeF67BQ5lHKo0B0pxZZTPY/fhj9HHuSErNZ5qpX9E1JwGeBpw/FcDsyoNDuQXNQdw7DNlHz08yrLvKxp2Jx+ZD4Q7Anft8AtKvZrlFWCF5XPjgcQTALI4GhL8YBMTh6tk= flafy@ope";
      # system = "";
    };
    mera = {
      user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCMFb8CoNiwcYM0XgGw2m0rMUP065/q+7VfssGH5ebL server@mera";
    };
    mane = {
      user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPn84OxYt3K7HwfpNPfA1cqbLMMlz3DjVEINeoVFD/it vps@mane";
    };
    bara = {
      user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC4kn/2R1/ED6zy4MTxbRNeISNhtbJUwG5s0qSIYQzY phone@bara";
    };
    noro = {
      user = "";
    };
  };

  # Can edit all secrets;
  master = ope.user;

  inherit (publicKeys) ope mera bara;
  inherit (builtins) readDir attrNames foldl' substring pathExists;

  concatPaths = paths: substring 1 (-1) (foldl' (acc: path: "${acc}/${toString path}") "" paths);

  sshKeys = foldl' (
    acc: host:
      acc
      // (foldl' (acc: key: let
        localPath = concatPaths ["ssh-keys" host key "private.age"];
      in
        acc
        // (
          {
            ${localPath}.publicKeys = [
              publicKeys.${host}.user
              master
            ];
          }
          # if pathExists (concatPaths [./. localPath])
          # then {
          #   ${localPath}.publicKeys = [
          #     publicKeys.${host}.user
          #     master
          #   ];
          # }
          # else {}
        )) {} (attrNames (readDir (concatPaths [./ssh-keys host]))))
  ) {} (attrNames (readDir ./ssh-keys));
in
  sshKeys
  // {
    "other/bitwarden.age".publicKeys = [
      ope.user
      mera.user
      bara.user
      master
    ];
    "other/porkbun.age".publicKeys = [
      ope.user
      mera.user
      master
    ];
    "other/mail/flafy_dev/flafy.age".publicKeys = [
      mera.user
      master
    ];
    # SYNCV3_SECRET=$(openssl rand -base64 32)
    "other/matrix_sliding_sync_secret.age".publicKeys = [
      mera.user
      master
    ];
    "other/lastfm-flafydev.age".publicKeys = [
      mera.user
      master
    ];
    "other/slskd.age".publicKeys = [
      mera.user
      master
    ];
    "other/restic-sb1-backups-password".publicKeys = [
      mera.user
      master
    ];

    # sshKeys.publicKeys = [
    #   ope.user
    # ];

    # Structure:
    # {
    #   "keyname": {
    #     "public": "content"
    #     "private": "content\ncontent\ncontent",
    #   }
    # }
    # To copy private and public files: `sed ':a;N;$!ba;s/\n/\\\n/g' <file> | tr -d '\n' | wl-copy`
    # "ope-private-keys.age".publicKeys = [
    #   # User
    #   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrGKIwxotjcyJh4nmp7ZqZVpGtQncoxG7ypTHCoQa1y685OD3F8g4ubBDwuigy7sfshXAA4eenxo3qL6WbNfJCJ3WTP0/6o3AxKTDj3cKt2+bbpOR1hPHuPb3Qn21ot6M+fvDqKZmkpWBls5Cze2U6+7WG5aO/rxXeC8sw4fEK12fhWXwysX6NUIoKh61s51IIr/L2pbhtE1C0yD7I6x3jjtrAxYS1+oBboTI5lSd87LZJTfAsQWmJc0hcEi44AEsgCfbOd2+l4fS3PGB7gKV1pNvKW2bCurqYLfZFNLMyMa8xA4H2iMOJoBJ8W810bFpWYuEGSWMFwCB+DunHYGRtgAnTqLbhx+//2Snz5QSDpt34WrFVOLHuxhVaSAD7inQeF67BQ5lHKo0B0pxZZTPY/fhj9HHuSErNZ5qpX9E1JwGeBpw/FcDsyoNDuQXNQdw7DNlHz08yrLvKxp2Jx+ZD4Q7Anft8AtKvZrlFWCF5XPjgcQTALI4GhL8YBMTh6tk="
    # ];
    # "mera-private-keys.age".publicKeys = [
    #   # User
    #   ""
    # ];
  }
