{ config, lib, pkgs, specialArgs, ... }:

(
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
      ./system.nix
      ../modules/gnome-xserver.nix
      ../modules/home-printer.nix
      ../modules/nix.nix
      ../configs/nixpkgs.nix
    ];

    time.timeZone = "Israel";

    environment.sessionVariables = rec {
      CHROME_EXECUTABLE = "chromium"; # For Flutter
    };

    users.users.flafydev = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
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
)
