{
  pkgs,
  inputs,
  config,
  lib,
  ssh,
  ...
}: {
  imports = [
    ./hardware
  ];

  hm.home.stateVersion = "23.11";
  users.main = "phone";
  users.host = "bara";

  os.services.xserver = {
    enable = false;
    desktopManager.plasma5.mobile.enable = false;
  };

  # os.mobile.boot.stage-1.kernel.modules = [
  #   "wireguard"
  # ];
  # os.mobile.boot.stage-1.kernel.modular = true;

  os.networking.wireguard = {
    enable = true;
    interfaces = {
      wg_private = {
        ips = ["10.10.11.12/32"];
        privateKeyFile = ssh.bara.bara_wg_private.private;
        peers = [
          {
            publicKey = builtins.readFile ssh.ope.ope_wg_private.public;
            allowedIPs = ["10.10.11.10/32"];
            endpoint = "flafy.me:51821";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  os.services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
  display.greetd.enable = true;
  display.greetd.command = "Hyprland";
  programs = {
    ssh = {
      enable = true;
      sftp.enable = true;

      matchBlocks = {
        ope-lan = {
          hostname = "ope.lan1.flafy.me";
          identitiesOnly = true;
          identityFile = [ssh.bara.bara_to_ope.private];
        };
        ope-private = {
          hostname = "ope.private.flafy.me";
          identitiesOnly = true;
          identityFile = [ssh.bara.bara_to_ope.private];
        };
      };

      server = {
        enable = true;

        users.${config.users.main}.keyFiles = [
          # (pkgs.writeText "ssh" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdqxBT2wLlydcxb31kmksQBMZDW1tm7Z0cddwvdyiF1 flafy@ope")
          ssh.ope.ope_to_bara.public
        ];
        users.root.keyFiles = [
          # (pkgs.writeText "ssh" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdqxBT2wLlydcxb31kmksQBMZDW1tm7Z0cddwvdyiF1 flafy@ope")
          ssh.ope.ope_to_bara.public
        ];
      };
    };

    nix.enable = true;
    nix.patch = false;
    anyrun.enable = true;
    foot.enable = true;
    fish.enable = true;
  };
  secrets.enable = true;
  secrets.autoBitwardenSession.enable = true; # TODO: remove redundant 
  bitwarden.enable = true;
  localhosts.enable = true;
  # programs.discord.enable = true;

  display.hyprland = {
    enable = true;
    monitors = [
      "DSI-1,1080x2280@60,0x0,2.5,transform,1"
    ];
  };

  assets.enable = true;

  themes.themeName = "amoled";
  fonts.enable = true;

  os.system.stateVersion = "23.11";
}
