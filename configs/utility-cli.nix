{
  system = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      nano
      wget
      parted
      neofetch
      unzip
      xclip
      service-wrapper
      htop
    ];
  };
}
