{
  pkgs,
  config,
  ssh,
  ...
}: {
  imports = [./hardware];

  users.main = "flafy";
  users.host = "ope";

  os = {
    networking = {
      hostName = config.users.host;
      firewall = {
        allowedUDPPorts = [51820 53317];
      };
      wireguard = {
        enable = true;
        interfaces.wg0 = {
          ips = [ "10.10.10.10/32" ];
          privateKeyFile = "";
          peers = [{
            # Public key of the server (not a file path).
            publicKey = "";

            # Forward all the traffic via VPN.
            allowedIPs = [ "10.10.10.1/32" ];
            # Or forward only particular subnets
            #allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];

            # Set this to the server IP and port.
            endpoint = "167.71.36.213:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

            # Send keepalives every 25 seconds. Important to keep NAT tables alive.
            persistentKeepalive = 25;
          }];
        };
      };
    };
  };

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

  os.services.openvscode-server = {
    enable = true;
    user = config.users.main;
    withoutConnectionToken = false;
    package = pkgs.openvscode-server.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ../mera/temppatch.patch
        ];
    });
    # host = "0.0.0.0";
    # port = 58846;
  };
  os.nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];

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

  os.networking.firewall = {
    enable = false;
    allowedTCPPorts = [53317];
  };

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

  themes.themeName = "amoled";

  localhosts.enable = true;
  vm.enable = true;
  games.enable = true;
  gtk.enable = true;
  games.services.minecraft.enable = true;

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

      matchBlocks = {
        mera = {
          identitiesOnly = true;
          identityFile = ["~/.ssh/ope_to_mera"];
        };
        "github.com" = {
          identitiesOnly = true;
          identityFile = ["~/.ssh/ope_flafydev_github"];
        };
      };

      server = {
        enable = true;
        users.${config.users.main}.keyFiles = [
          ssh.mera.mera_to_ope.public
        ];
      };
    };
    discord.enable = true;
    gui-utils.enable = true;
  };
}
