# Not imported by nix. Used by agenix's cli too.
let
  user1 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrGKIwxotjcyJh4nmp7ZqZVpGtQncoxG7ypTHCoQa1y685OD3F8g4ubBDwuigy7sfshXAA4eenxo3qL6WbNfJCJ3WTP0/6o3AxKTDj3cKt2+bbpOR1hPHuPb3Qn21ot6M+fvDqKZmkpWBls5Cze2U6+7WG5aO/rxXeC8sw4fEK12fhWXwysX6NUIoKh61s51IIr/L2pbhtE1C0yD7I6x3jjtrAxYS1+oBboTI5lSd87LZJTfAsQWmJc0hcEi44AEsgCfbOd2+l4fS3PGB7gKV1pNvKW2bCurqYLfZFNLMyMa8xA4H2iMOJoBJ8W810bFpWYuEGSWMFwCB+DunHYGRtgAnTqLbhx+//2Snz5QSDpt34WrFVOLHuxhVaSAD7inQeF67BQ5lHKo0B0pxZZTPY/fhj9HHuSErNZ5qpX9E1JwGeBpw/FcDsyoNDuQXNQdw7DNlHz08yrLvKxp2Jx+ZD4Q7Anft8AtKvZrlFWCF5XPjgcQTALI4GhL8YBMTh6tk= flafy@ope";
  users = [ user1 ];

  systems = [ ];
in
{
  "bitwarden.age".publicKeys = users ++ systems;
}
