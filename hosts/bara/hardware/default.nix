{
  pkgs,
  inputs,
  lib,
  ...
}: {
  inputs = {
    mobile-nixos = {
      url = "github:nixos/mobile-nixos/master";
      flake = false;
    };
    mobile-nixos-nixpkgs.url = "github:nixos/nixpkgs/684c17c429c42515bafb3ad775d2a710947f3d67";
    mobile-nixos-home-manager = {
      url = "github:nix-community/home-manager/8c350c2069ac3eed6344fa62e3249afa0ce2728c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  osModules = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" {device = "oneplus-enchilada";})
  ];

  unfree.allowed = [
    "oneplus-sdm845-firmware-xz"
    "oneplus-sdm845-firmware"
  ];

  os = lib.mkMerge [
    {
      mobile.beautification = {
        silentBoot = lib.mkDefault true;
        splash = lib.mkDefault true;
      };

      hardware.bluetooth.enable = true;
      hardware.pulseaudio.enable = lib.mkDefault true; # mkDefault to help out users wanting pipewire
      networking.networkmanager.enable = true;
      networking.wireless.enable = false;
      powerManagement.enable = true;
    }
    # # INSECURE STUFF FIRST
    # # Users and hardcoded passwords.
    # {
    #   # Forcibly set a password on users...
    #   # Note that a numeric password is currently required to unlock a session
    #   # with the plasma mobile shell :/
    #   users.users.${defaultUserName} = {
    #     isNormalUser = true;
    #     # Numeric pin makes it **possible** to input on the lockscreen.
    #     password = "1234";
    #     home = "/home/${defaultUserName}";
    #     extraGroups = [
    #       "dialout"
    #       "feedbackd"
    #       "networkmanager"
    #       "video"
    #       "wheel"
    #     ];
    #     uid = 1000;
    #   };
    #
    #   users.users.root.password = "nixos";
    #
    #   # Automatically login as defaultUserName.
    #   services.xserver.displayManager.autoLogin = {
    #     user = defaultUserName;
    #   };
    # }

    # Networking, modem and misc.
    {
      # Ensures any rndis config from stage-1 is not clobbered by NetworkManager
      networking.networkmanager.unmanaged = ["rndis0" "usb0"];

      # Setup USB gadget networking in initrd...
      mobile.boot.stage-1.networking.enable = lib.mkDefault true;
    }
  ];
}
