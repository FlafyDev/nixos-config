{
  lib,
  config,
  hmConfig,
  inputs,
  options,
  osOptions,
  ...
}: let
  cfg = config.programs.ssh;
  inherit (lib) mkEnableOption mkOption types mkIf mkMerge;
  inherit (builtins) mapAttrs;
in {
  options.programs.ssh = {
    enable = mkEnableOption "ssh";

    matchBlocks = mkOption {
      default = {};
      inherit ((osOptions.home-manager.users.type.getSubOptions []).programs.ssh.matchBlocks) type;
    };

    server = {
      enable = mkEnableOption "ssh-server";

      users = mkOption {
        default = {};
        type = with types;
          attrsOf (submodule (
            _: {
              options.keyFiles = mkOption {
                type = with types; listOf path;
                default = [];
                description = lib.mdDoc ''
                  A list of files each containing one OpenSSH public key that should be
                  added to the user's authorized keys. The contents of the files are
                  read at build time and added to a file that the SSH daemon reads in
                  addition to the the user's authorized_keys file. You can combine the
                  `keyFiles` and `keys` options.
                '';
              };
            }
          ));
        example = {
          user1 = [
            ./key
          ];
        };
        description = ''
          A list of files containing SSH public keys for users.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.server.enable) {
      os.services.openssh = {
        enable = true;
        settings = {
          # require public key authentication for better security
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          # GatewayPorts = "yes";
          PermitRootLogin = "yes";
        };
      };
      os.users.users =
        mapAttrs (_name: user: {
          openssh.authorizedKeys.keyFiles = user.keyFiles;
        })
        cfg.server.users;
    })
    (mkIf cfg.enable {
      hm.programs.ssh = {
        enable = true;
        inherit (cfg) matchBlocks;
        # # TODO: update home-manager and use option.
        # extraConfig = ''
        #   Host *
        #     AddKeysToAgent "yes";
        # '';
      };
      hm.services.ssh-agent.enable = true;
      os.programs.ssh.startAgent = false;
      os.systemd.user.services.ssh-agent.environment.SSH_ASKPASS_REQUIRE = "prefer";
      # os.services.gnome.gnome-keyring.enable = true;
      # hm.services.gnome-keyring = {
      #   enable = true;
      #   components = ["pkcs11" "secrets" "ssh"];
      # };

      # os = {
      #   # security.pam.services.login.enableGnomeKeyring = true;
      #   # security.pam.services.greetd.enableGnomeKeyring = true;
      #   # programs.seahorse.enable = true;
      # };

      # hm.home.sessionVariables = {
      #   SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      # };
    })
  ];
}
