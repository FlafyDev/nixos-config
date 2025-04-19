# TODO: glint rename to pika
{ config, pkgs, secrets, ... }:

{
  # SSH
  #
  # gnome
  # printer
  # user
  # cli / gui utils

  imports = [
    ./hardware
  ];

  os.nixpkgs.config.allowUnfree = true;

  programs.ssh = {
    enable = true;

    server = {
      enable = true;
      users.${config.users.main}.keyFiles = [
        secrets.ssh-keys.ope.ope_to_glint.public.filePath
      ];
    };
  };

  users.main = "flafy";
  users.host = "glint";

  utils.enable = true;

  # flatpak
  os.services.flatpak.enable = true;
  hm.home.packages = with pkgs; [
    flatpak
    gnome-software
  ];

  games.enable = true;

  fonts.enable = true;
  printers.enable = true;

  themes.themeName = "amoled";
  assets.enable = true;

  # bitwarden.enable = true;

  secrets.enable = true;

  gtk.enable = true;

  programs = {
    firefox.enable = true;
    gnome.enable = true;
    mpv.enable = true;
    neovim.enable = true;
    cli-utils.enable = true;
    transmission.enable = false;
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

  os.programs.corectrl.enable = true;

  # services.waypipe.client.enable = true;
  # services.waypipe.client.ip = "10.10.11.10";

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

  # Audio
  os.services.pulseaudio.enable = false;
  os.services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Time and langauge
  os.time.timeZone = "Asia/Jerusalem";
  os.i18n.defaultLocale = "en_IL";

  os.system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
