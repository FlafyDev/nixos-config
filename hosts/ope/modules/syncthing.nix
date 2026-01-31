{config, ...}:

{
  os.services.syncthing = rec {
    enable = true;
    group = "users";
    user = config.users.main;
    dataDir = "/home/${user}/.syncthing";
    settings = {
      folders = {
        "Notes" = {
          path = "/home/flafy/repos/flafydev/notes";
          ignorePerms = false; # Enable file permission syncing
        };
      };
    };
  };
}