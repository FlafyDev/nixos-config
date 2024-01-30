{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware
  ];

  hm.home.stateVersion = "23.11";
  users.main = "phone";
  users.host = "bara";

  programs = {
    ssh = {
      enable = true;
      sftp.enable = true;

      server = {
        enable = true;

        users.${config.users.main}.keyFiles = [
          (pkgs.writeText "ssh" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdqxBT2wLlydcxb31kmksQBMZDW1tm7Z0cddwvdyiF1 flafy@ope")
        ];
        users.root.keyFiles = [
          (pkgs.writeText "ssh" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdqxBT2wLlydcxb31kmksQBMZDW1tm7Z0cddwvdyiF1 flafy@ope")
        ];
      };
    };
  };

  display.greetd.enable = true;
  display.greetd.command = "Hyprland";

  display.hyprland = {
    enable = true;
  };

  assets.enable = true;

  themes.themeName = "amoled";
  # fonts.enable = true;

  os = lib.mkMerge [
    {
      system.stateVersion = "23.11";
    }

    # {
    #   services.xserver = {
    #     enable = true;
    #
    #     desktopManager.plasma5.mobile.enable = true;
    #
    #     displayManager.autoLogin = {
    #       enable = true;
    #       user = config.users.main;
    #     };
    #
    #     displayManager.defaultSession = "plasma-mobile";
    #
    #     displayManager.lightdm = {
    #       enable = true;
    #       # Workaround for autologin only working at first launch.
    #       # A logout or session crashing will show the login screen otherwise.
    #       extraSeatDefaults = ''
    #         session-cleanup-script=${pkgs.procps}/bin/pkill -P1 -fx ${pkgs.lightdm}/sbin/lightdm
    #       '';
    #     };
    #
    #     libinput.enable = true;
    #   };
    #
    #   environment.systemPackages = with pkgs; [
    #     gnome.gnome-system-monitor
    #     kitty
    #     foot
    #     alacritty
    #     sway
    #   ];
    #
    #   # services.greetd = {
    #   #   enable = true;
    #   #   settings = {
    #   #     default_session = {
    #   #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd \"${pkgs.hyprland}/bin/Hyprland\"";
    #   #       user = "alice";
    #   #     };
    #   #   };
    #   # };
    #
    #   # services.greetd = let
    #   #   swayConfig = pkgs.writeText "greetd-sway-config" ''
    #   #     # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
    #   #     exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
    #   #     bindsym Mod4+shift+e exec swaynag \
    #   #       -t warning \
    #   #       -m 'What do you want to do?' \
    #   #       -b 'Poweroff' 'systemctl poweroff' \
    #   #       -b 'Reboot' 'systemctl reboot'
    #   #   '';
    #   # in {
    #   #   enable = true;
    #   #   settings = {
    #   #     default_session = {
    #   #       # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd \"offload-igpu Hyprland\"";
    #   #       command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
    #   #       user = "alice";
    #   #     };
    #   #   };
    #   # };
    #   #
    #   # environment.etc."greetd/environments".text = ''
    #   #   sway
    #   #   fish
    #   #   bash
    #   #   startxfce4
    #   # '';
    # }
    # INSECURE STUFF FIRST
    # Users and hardcoded passwords.
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
  ];
}
