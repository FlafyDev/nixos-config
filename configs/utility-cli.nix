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
    cp-maps = {
      url = "github:flafydev/cp-maps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    project-creator = {
      url = "github:flafydev/project_creator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {
    lang-to-docx,
    tofi-rbw,
    cp-maps,
    project-creator,
    ...
  }: {
    overlays = _: [
      lang-to-docx.overlays.default
      tofi-rbw.overlays.default
      cp-maps.overlays.default
      project-creator.overlays.default
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
      cp-maps
      project-creator
    ];
  };
}
