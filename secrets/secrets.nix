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
  };

  # Can edit all secrets;
  masterPC = ope;

  inherit (publicKeys) ope mera;
  inherit (builtins) readDir attrNames foldl' substring;

  concatPaths = paths: substring 1 (-1) (foldl' (acc: path: "${acc}/${toString path}") "" paths);

  sshKeys = foldl' (
    acc: host:
      acc
      // (foldl' (acc: key:
        acc
        // {
          ${concatPaths ["ssh-keys" host key "private.age"]}.publicKeys = [
            publicKeys.${host}.user
            masterPC.user
          ];
        }) {} (attrNames (readDir (concatPaths [./ssh-keys host]))))
  ) {} (attrNames (readDir ./ssh-keys));
in
  sshKeys
  // {
    "other/bitwarden.age".publicKeys = [
      ope.user
      mera.user
      masterPC.user
    ];
    "other/flafy_me-cert.age".publicKeys = [
      ope.user
      mera.user
      masterPC.user
    ];
    "other/flafy_me-key.age".publicKeys = [
      ope.user
      mera.user
      masterPC.user
    ];
    "other/flafy_me-pass.age".publicKeys = [
      ope.user
      mera.user
      masterPC.user
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
