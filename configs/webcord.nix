{
  system = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      webcord-vencord
    ];
  };
}
