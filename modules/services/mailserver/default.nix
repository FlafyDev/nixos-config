{
  config,
  pkgs,
  osConfig,
  secrets,
  inputs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    mkMerge
    ;
  cfg = config.services.mailserver;
in {
  options.services.mailserver = {
    enable = mkEnableOption "mailserver";
    host = mkOption {
      type = types.str;
      description = "The domain name of the Mailserver server";
    };
    cert = mkOption {
      type = types.str;
      description = "The name of the certificates";
    };
  };

  config = mkMerge [
    {
      inputs = {
        nixos-mailserver = {
          url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
          inputs = {
            nixpkgs.follows = "nixpkgs";
            nixpkgs-23_05.follows = "nixpkgs";
            nixpkgs-23_11.follows = "nixpkgs";
          };
        };
      };
    }
    (mkIf cfg.enable {
      osModules = [
        inputs.nixos-mailserver.nixosModules.mailserver
      ];

      os.services.postfix.config.inet_protocols = "ipv4";

      os.mailserver = {
        enable = true;
        debug = true;
        fqdn = "mail.${cfg.host}";
        domains = [cfg.host];

        # TODO: acme over manual?
        certificateScheme = "manual";
        certificateFile = "/var/lib/acme/${cfg.cert}/cert.pem";
        keyFile = "/var/lib/acme/${cfg.cert}/key.pem";

        # A list of all login accounts. To create the password hashes, use
        # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
        loginAccounts = {
          # Personal
          "flafy@${cfg.host}" = {
            hashedPasswordFile = secrets."mail.flafy_dev.flafy";
          };
          # "user1@example.com" = {
          #   hashedPasswordFile = "/a/file/containing/a/hashed/password";
          #   aliases = ["postmaster@example.com"];
          # };
          # "user2@example.com" = { ... };
        };

        # Use Let's Encrypt certificates. Note that this needs to set up a stripped
        # down nginx and opens port 80.
        # certificateScheme = "acme-nginx";
      };
    })
  ];
}
