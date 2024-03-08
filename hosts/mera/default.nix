{
  config,
  ssh,
  pkgs,
  utils,
  osConfig,
  ...
}: let
  inherit (utils) domains;
in {
  imports = [./hardware];

  users.main = "server";
  users.host = "mera";

  # boot.enableContainers = false;

  secrets.enable = true;
  printers.enable = true;

  networking.enable = true;

  # networking.allowedPorts.tcp."22" = ["*"];
  # programs.ssh = {
  #   enable = true;
  #   sftp.enable = true;
  #
  #   matchBlocks = {
  #     ope = {
  #       identitiesOnly = true;
  #       identityFile = [ssh.mera.mera_to_ope.private];
  #     };
  #   };
  #
  #   server = {
  #     enable = true;
  #
  #     users.${config.users.main}.keyFiles = [
  #       ssh.ope.ope_to_mera.public
  #     ];
  #     users.root.keyFiles = [
  #       ssh.ope.ope_to_mera.public
  #     ];
  #   };
  # };

  services = {
    games = {
      badTimeSimulator = {
        enable = true;
        port = 40004;
      };
      minecraft.enable = false;
    };
  };

  # networking.vpnNamespace.vpn.ports.tcp = ["25" "143" "993" "587" "465"];
  #
  # containers.maneVpn.config.services.mailserver = {
  #   enable = true;
  #   host = domains.personal;
  #   cert = "_.${domains.personal}";
  # };

  programs = {
    git.enable = true;
    nix.enable = true;
    fish.enable = true;
  };
}
