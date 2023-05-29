{
  inputs = {
    lang-to-docx = {
      url = "github:FlafyDev/lang-to-docx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cp-maps = {
      url = "github:flafydev/cp-maps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    project-creator = {
      url = "github:flafydev/project_creator";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dart-flutter.follows = "dart-flutter";
    };
  };

  add = {
    lang-to-docx,
    cp-maps,
    project-creator,
    ...
  }: {
    overlays = _: [
      lang-to-docx.overlays.default
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
      bat
      exa
      service-wrapper
      distrobox
      wl-clipboard
      drm_info
      libnotify
      # lang-to-docx
      htop
      btop
      tree
      # cp-maps
      project-creator
      vdpauinfo
      pciutils
      binutils
      intel-gpu-tools
      libva-utils
      nur.repos.mic92.noise-suppression-for-voice
    ];
  };
}
