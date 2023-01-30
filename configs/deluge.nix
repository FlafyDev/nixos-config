{
  system = { pkgs, ... }: {
    services.deluge = {
      enable = true;
      web.enable = true;
    };

    # environment.systemPackages = with pkgs; [
    #   transmission
    #   transmission-qt
    # ];
  };
}
