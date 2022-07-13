{ config, lib, pkgs, specialArgs, ... }:

let
  packages = import ./packages.nix;
  inherit (args) localOverlay;
in
[
  (import ./system.nix)
  (import ../modules/gnome.nix)
  (import ../modules/vscode.nix)
  (import ../modules/home-printer.nix)
  {
    nix = {
      package = nixpkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    services.xserver.libinput = {
      enable = true;
      mouse = {
        accelSpeed = "-0.78";
        accelProfile = "flat";
      };
    };

    imports = [
      ./hardware-configuration.nix
      home-manger.nixosModule
    ];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ localOverlay ];

    time.timeZone = "Israel";

    environment.sessionVariables = rec {
      CHROME_EXECUTABLE = "chromium"; # For Flutter
    };

    programs.home-manager.enable = true;

    home = {

    };
  }
]