{
  pkgs,
  inputs,
  lib,
  ...
}: {
  inputs = {
    mobile-nixos = {
      url = "github:nixos/mobile-nixos/development";
      # url = "github:nixos/mobile-nixos/master";
      flake = false;
    };
    # mobile-nixos-nixpkgs.url = "github:nixos/nixpkgs/684c17c429c42515bafb3ad775d2a710947f3d67";
    # mobile-nixos-home-manager = {
    #   url = "github:nix-community/home-manager/8c350c2069ac3eed6344fa62e3249afa0ce2728c";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  osModules = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = "oneplus-enchilada";})
  ];

  unfree.allowed = [
    "oneplus-sdm845-firmware-xz"
    "oneplus-sdm845-firmware"
  ];

  os = {
    hardware.sensor.iio.enable = true;
    mobile.beautification = {
      silentBoot = lib.mkDefault true;
      splash = lib.mkDefault true;
    };

    hardware.bluetooth.enable = true;
    hardware.pulseaudio.enable = lib.mkDefault true; # mkDefault to help out users wanting pipewire
    networking.networkmanager.enable = true;
    networking.wireless.enable = false;
    powerManagement.enable = true;

    # Ensures any rndis config from stage-1 is not clobbered by NetworkManager
    networking.networkmanager.unmanaged = ["rndis0" "usb0"];

    # Setup USB gadget networking in initrd...
    mobile.boot.stage-1.networking.enable = lib.mkDefault true;
  };
}
