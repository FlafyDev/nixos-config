{
  pkgs,
  config,
  ssh,
  lib,
  ...
}: let
  inherit (lib) optional;
  inherit (builtins) pathExists;
in {
  osModules = [
    ({modulesPath, ...}: {
      imports =
        optional (pathExists ./do-userdata.nix) ./do-userdata.nix
        ++ [
          (modulesPath + "/virtualisation/digital-ocean-config.nix")
        ];
    })
  ];

  os = {
    networking = {
      firewall = {
        allowedUDPPorts = [51820];
      };
      wireguard = {
        enable = true;
        interfaces.wg0 = {
          ips = [ "10.10.10.1/24" ];
          listenPort = 51820;
          privateKeyFile = "";
          peers = [{
            # Public key of the server (not a file path).
            publicKey = "";

            # Forward all the traffic via VPN.
            allowedIPs = [ "10.10.10.10/32" ];
          }];
        };
      };
    };
  };


  os.networking.firewall = {
    enable = true;
    allowedTCPPorts = [3000 80];
    # allowedUDPPorts = [58846 25565 80 21 22];
  };

  os.virtualisation.digitalOcean.setSshKeys = false;

  os.system.stateVersion = "23.05";
  hm.home.stateVersion = "23.05";

  users.main = "vps";
  users.host = "mane";
  os.networking.hostName = config.users.host;

  secrets.enable = true;
  # printers.enable = true;

  # bitwarden.enable = true;

  # os.services.openvscode-server = {
  #   enable = true;
  #   user = "server";
  #   withoutConnectionToken = true;
  #   package = pkgs.openvscode-server.overrideAttrs (old: {
  #     patches =
  #       (old.patches or [])
  #       ++ [
  #         ./temppatch.patch
  #       ];
  #   });
  #   # host = "0.0.0.0";
  #   # port = 58846;
  # };
  # os.nixpkgs.config.permittedInsecurePackages = [
  #   "nodejs-16.20.2"
  # ];

  # programs.neovim.enable = true;
  # programs.cli-utils.enable = true;
  # programs.transmission.enable = true;
  # programs.direnv.enable = true;
  # programs.fish.enable = true;
  # programs.git.enable = true;
  programs.nix.enable = true;
  programs.git.enable = true;
  programs.ssh = {
    enable = true;
    server = {
      enable = true;
      users.${config.users.main}.keyFiles = [
        ssh.ope.ope_to_mane.public
      ];
    };
  };
  users.groups = ["sftpuser"];

  os.services.vsftpd = {
    enable = true;
    #   cannot chroot && write
    #    chrootlocalUser = true;
    writeEnable = true;
    localUsers = true;
    # userlist = ["martyn" "cam"];
    # userlistEnable = true;
    # anonymousUserNoPassword = true;
    # anonymousUser = true;
  };
}
