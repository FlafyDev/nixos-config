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
      intel-gpu-tools
      lang-to-docx
      htop
      tofi-rbw
    ];
  };
}
