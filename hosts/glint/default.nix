{ config, pkgs, ssh, ... }:

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
        ssh.ope.ope_to_glint.public
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
    vscode.enable = true;
    neovim.enable = true;
    cli-utils.enable = false;
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

  os.programs.corectrl.enable = true;

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
