# TODO
# make 2 different profiles for gnome and i3vm.
# done - get eww bar to work and think of a way to do the scripts.
# get transparency and blur for terminal (please picom work)
# set background

let
  mkHome = import ../utils/mk-home.nix;
  username = "flafydev";
in
mkHome username {
  configs = [
    /direnv.nix
    /git.nix
    # /gnome.nix
    /mpv.nix
    /nix.nix
    /printer-4500.nix
    /vscode.nix
    /wine.nix
    /zsh.nix
    /steam.nix
    /mouse-g502.nix
    /neovim
    /i3.nix
    /alacritty.nix
    /picom.nix
    /keyboard
    /betterdiscord.nix
    /eww
    /rofi
    /gtk.nix
    /utility-software.nix
  ];

  system = { pkgs, ... }: {
    time.timeZone = "Israel";

    programs = {
      adb.enable = true;
      kdeconnect.enable = true;
    };

    services.xserver.libinput = {
      enable = true;
      touchpad = {
        tapping = true;
      };
    };

    environment.systemPackages = with pkgs; [
      nano
      wget
      parted
      git
      neofetch
      unzip
      gh
      xclip
      service-wrapper
    ];
  };

  home = ({ pkgs, lib, ... }: {
    home.packages = with pkgs; [
      syncplay
      qbittorrent
      polymc
      element-desktop
      libstrangle
      yt-dlp
      termusic
      godot
      guake
      gparted
      firefox
      chromium
      qdirstat
      htop
      scrcpy
    ];
    home.file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";
  });
}
