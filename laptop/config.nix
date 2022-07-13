{ config, lib, pkgs, specialArgs, ... }:

[
  (import ./system.nix)
  (import ../modules/gnome-xserver.nix)
  (import ../modules/home-printer.nix)
  (import ../modules/nix.nix)
  (import ../config/nixpkgs.nix)
  {
    services.xserver.libinput = {
      enable = true;
      mouse = {
        accelSpeed = "-0.78";
        accelProfile = "flat";
      };
    };

    imports = [
      ./hardware-configuration.nix
    ];

    time.timeZone = "Israel";

    environment.sessionVariables = rec {
      CHROME_EXECUTABLE = "chromium"; # For Flutter
    };

    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      };
    };

    fonts.fonts = with pkgs; [
      # segoe-ui
    ];

    environment.systemPackages = with pkgs; [
      nano
      wget
      firefox
      parted
      gparted
      dig
      btop
      git
      qbittorrent
      neofetch
      pfetch
      unzip
      gh
      ulauncher
      filezilla
      gnome.gnome-tweaks
      gnome.dconf-editor
      xclip
      fish
      pciutils
      nvidia-offload
      xdotool
      dotnet-sdk
      guake
      woeusb
      cmake
      clang
      ninja
      pkg-config
      gtk3
      python3
    ];
  }
]