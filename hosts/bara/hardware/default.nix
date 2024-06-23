{
  pkgs,
  inputs,
  lib,
  ...
}: {
  inputs = {
    mobile-nixos = {
      url = "github:nixos/mobile-nixos/8f9ce9d7e7e71b2d018039332e04c5be78f0a6b7";
      # url = "github:nixos/mobile-nixos/master";
      flake = false;
    };
    nixpkgs-bara.url = "github:nixos/nixpkgs/684c17c429c42515bafb3ad775d2a710947f3d67";
    # mobile-nixos-nixpkgs.url = "github:nixos/nixpkgs/684c17c429c42515bafb3ad775d2a710947f3d67";
    # mobile-nixos-home-manager = {
    #   url = "github:nix-community/home-manager/8c350c2069ac3eed6344fa62e3249afa0ce2728c";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # os.nixpkgs.overlays = [
  #   (_final: prev: let
  #     baraPkgs = import inputs.nixpkgs-bara {
  #       inherit (prev) system;
  #     };
  #   in {
  #     inherit (baraPkgs) mesa;
  #   })
  # ];

  osModules = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = "oneplus-enchilada";})
  ];

  unfree.allowed = [
    "oneplus-sdm845-firmware-xz"
    "oneplus-sdm845-firmware"
  ];

  os = {
    hardware = {
      sensor.iio.enable = true;

      bluetooth.enable = true;
      pulseaudio.enable = lib.mkDefault true;
    };
    mobile = {
      boot.stage-1.networking.enable = true;
      beautification = {
        silentBoot = lib.mkDefault true;
        splash = lib.mkDefault true;
      };
    };
    networking = {
      # mkDefault to help out users wanting pipewire
      networkmanager.enable = true;
      wireless.enable = false;

      # Ensures any rndis config from stage-1 is not clobbered by NetworkManager
      networkmanager.unmanaged = ["rndis0" "usb0"];
    };
    powerManagement.enable = true;
  };
}
