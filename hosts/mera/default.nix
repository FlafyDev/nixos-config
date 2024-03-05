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

  # networking.vpsForwarding.mane.tcp = ["143" "993" "587" "465"];
  services.mailserver = {
    enable = true;
    host = domains.personal;
    cert = "_.${domains.personal}";
  };

  os.security.acme = {
    acceptTerms = true;
    defaults.email = "flafyarazi@gmail.com";
    certs."flafy.dev" = {
      domain = "flafy.dev";
      group = "nginx";
      dnsProvider = "porkbun";
      # env file with PORKBUN_SECRET_API_KEY PORKBUN_API_KEY
      credentialsFile = osConfig.age.secrets.porkbun.path;
    };
    certs."_.flafy.dev" = {
      domain = "*.flafy.dev";
      group = "nginx";
      dnsProvider = "porkbun";
      # env file with PORKBUN_SECRET_API_KEY PORKBUN_API_KEY
      credentialsFile = osConfig.age.secrets.porkbun.path;
    };
  };

  services.matrix = {
    enable = true;
    host = domains.personal;
  };

  programs = {
    git.enable = true;
    nix.enable = true;
    fish.enable = true;
  };
}
