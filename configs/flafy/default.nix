{pkgs, ...}: {
  users.main = "flafy";

  # os.services = {
  #   xserver = {
  #     enable = true;
  #     dpi = 96;
  #     videoDrivers = ["amdgpu"];
  #     autorun = false;
  #   };
  # };
  # os.services.xserver.desktopManager.plasma5.enable = true;
  # os.programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

  android.enable = true;
  display.greetd.enable = true;
  display.hyprland = {
    enable = true;
    headlessXorg.enable = true;
  };
  fonts.enable = true;
  printers.enable = true;
  bitwarden.enable = true;

  assets.enable = true;

  secrets.enable = true;
  secrets.autoBitwardenSession.enable = true;

  themes.themeName = "amoled";

  localhosts.enable = true;
  vm.enable = true;
  games.enable = true;
  gtk.enable = true;

  # TEMP
  os.nixpkgs.overlays = [
    (final: prev: {
      makeDBusConf = {
        suidHelper,
        serviceDirectories,
        apparmor ? "disabled",
      }:
        prev.makeDBusConf {
          serviceDirectories = serviceDirectories ++ ["/home/flafy/.testshare"];
          inherit suidHelper apparmor;
        };
    })
  ];

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
    nix.enable = true;
    ssh = {
      enable = true;
      server = true;
    };
    discord.enable = true;
    gui-utils.enable = true;
  };
}
