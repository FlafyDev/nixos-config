{
  config,
  ssh,
  ...
}: {
  imports = [./hardware];

  users.main = "server";
  users.host = "mera";

  secrets.enable = true;
  printers.enable = true;

  networking.enable = true;

  services = {
    games = {
      badTimeSimulator = {
        enable = true;
        port = 40004;
      };
      minecraft.enable = false;
    };
  };

  os.networking.firewall.enable = true;

  programs = {
    git.enable = true;
    nix.enable = true;
    fish.enable = true;
  };
}
