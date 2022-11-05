{
  inputs = {
    lang-to-docx = {
      url = "github:FlafyDev/lang-to-docx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tofi-rbw = {
      url = "github:FlafyDev/tofi-rbw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {lang-to-docx, tofi-rbw, ...}: {
    overlays = _: [
      lang-to-docx.overlays.default
      tofi-rbw.overlays.default
    ];
  };

  system = {pkgs, ...}: {
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
      pciutils
    ];
  };
}
