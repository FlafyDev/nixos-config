{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.gtk;
  inherit (lib) mkEnableOption mkIf;
in {
  options.gtk = {
    enable = mkEnableOption "gtk";
  };

  config = mkIf cfg.enable {
    os.nixpkgs.overlays = [
      (_final: prev: {
        adwaita-dark-amoled = prev.callPackage ./adwaita-dark-amoled.nix {};
        colloid-dark-edit = prev.callPackage ./colloid-dark-edit.nix {};
      })
    ];
    hm = {
      home.packages = [pkgs.dconf];
      dconf.enable = true;
      gtk = {
        enable = true;

        gtk3.extraConfig = {
          gtk-decoration-layout = ":menu"; # disable title bar buttons
          gtk-application-prefer-dark-theme = 1;
        };

        cursorTheme = {
          name = "Bibata-Modern-Ice";
          size = 24;
          package = pkgs.bibata-cursors;
        };

        font = {
          name = "Roboto";
          package = pkgs.google-fonts;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        theme = {
          # name = "Tokyonight-Moon-BL"; # Moon = Night ?
          # package = pkgs.tokyo-night-gtk;
          # name = "Adwaita-dark-amoled"; # Moon = Night ?
          # package = pkgs.adwaita-dark-amoled;
          name = "Colloid-Dark-Edit"; # Moon = Night ?
          package = pkgs.colloid-dark-edit;
        };
      };
    };
  };
}
