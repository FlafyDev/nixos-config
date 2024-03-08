{
  lib,
  utils,
  pkgs,
  ...
}: let
  inherit (utils) getHostname domains;
in {
  imports = [./hardware];

  users.main = "flafy";
  users.host = "ope";

  os = {
    boot.binfmt.emulatedSystems = ["aarch64-linux"];
    services.prometheus = {
      enable = true;
      port = 4000;
      exporters.node = {
        enable = true;
        port = 9100;
        listenAddress = getHostname "ope.wg_private";
      };

      globalConfig = {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
    };
  };

  os.services.nginx = {
    enable = true;
    virtualHosts."emoji.${domains.personal}" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 3004;
          ssl = false;
        }
      ];
      locations."/api" = {
        proxyPass = "http://localhost:40003";
      };
      locations."/" = {
        proxyPass = "http://localhost:40002";
      };
    };
  };

  os.security = {
    rtkit.enable = true;
    pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile"; # max FD count
        value = "unlimited";
      }
    ];
  };

  android.enable = true;
  display.greetd.enable = true;
  display.greetd.command = "offload-igpu Hyprland";

  # TCP: 47984, 47989, 48010
  # UDP: 47998-48000, 48002, 48010

  networking.allowedPorts.tcp."47984,47989,48010" = [(getHostname "ope.wg_private")];
  networking.allowedPorts.udp."47998-48000" = [(getHostname "ope.wg_private")];
  networking.allowedPorts.udp."48002,48010" = [(getHostname "ope.wg_private")];

  display.hyprland = {
    enable = true;
    headlessXorg.enable = true;
    monitors = [
      "eDP-1,disable"
      "HDMI-A-1,1920x1080@60,0x0,1"
      "HDMI-A-1,addreserved,0,40,0,0"
      "HDMI-A-2,1920x1080@60,0x0,1"
      "HDMI-A-2,addreserved,0,40,0,0"
    ];
  };
  fonts.enable = true;
  printers.enable = true;

  bitwarden.enable = true;

  assets.enable = true;

  networking.enable = true;

  secrets.enable = true;

  themes.themeName = "amoled";

  vm.enable = true;
  games.enable = true;
  gtk.enable = true;

  programs = {
    anyrun.enable = true;
    firefox.enable = true;
    gnome.enable = false;
    mpv.enable = true;
    vscode.enable = true;
    neovim.enable = true;
    cli-utils.enable = true;
    transmission.enable = true;
    direnv.enable = true;
    fish.enable = true;
    foot.enable = true;
    alacritty.enable = true;
    git.enable = true;
    nix = {
      enable = true;
      patch = true;
    };
    discord.enable = true;
    gui-utils.enable = true;
  };
}
