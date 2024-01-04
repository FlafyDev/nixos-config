{
  lib,
  config,
  pkgs,
  hmConfig,
  ssh,
  ...
}: let
  cfg = config.bitwarden;
  inherit (lib) mkEnableOption mkIf;
  askpass = toString (pkgs.writeShellScript "ask-password" ''
    key_name="$1"
    key_name="''${key_name##*/}"
    key_name="''${key_name##*-}"
    key_name="''${key_name%%:*}"
    key_name="''${key_name//\'/}"

    echo "$key_name" >&2
    pass=$(${pkgs.get-password}/bin/get-password "ssh $key_name" --exact)

    if [ $? -eq 0 ]; then
      echo "$pass"
    else
      echo "Couldn't find passphrase from Bitwarden." >&2
      read -s -p "$1" passphrase
      echo "" >&2
      echo "$passphrase"
    fi
  '');
in {
  options.bitwarden = {
    enable = mkEnableOption "bitwarden";
  };

  config = mkIf cfg.enable {
    secrets.autoBitwardenSession.enable = mkIf config.secrets.enable true;

    os.programs.ssh = {
      enableAskPassword = true;
      askPassword = askpass;
    };

    # hm.systemd.user.services.ssh-agent-add-ssh = mkIf hmConfig.services.ssh-agent.enable {
    #   # Service.ExecStart = lib.mkForce "SSH_ASKPASS_REQUIRE=\"prefer\" SSH_ASKPASS=\"${askpass}\" ${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
    #   Install.WantedBy = [ "default.target" ];
    #
    #   Unit = {
    #     Description = "Adds SSH keys after ssh-agent is available";
    #     After = [ "ssh-agent.service" ];
    #   };
    #
    #   Service = {
    #     ExecStart = pkgs.writeShellScript "ssh-agent-post" ''
    #       echo -------------
    #       echo $SSH_ASKPASS_REQUIRE
    #       echo $SSH_ASKPASS
    #       echo $DISPLAY
    #       echo $SSH_AUTH_SOCK
    #       ${pkgs.openssh}/bin/ssh-add ~/.ssh/ope_to_mane
    #     '';
    #     Environment = [
    #       "SSH_ASKPASS_REQUIRE=prefer"
    #       "SSH_ASKPASS=${askpass}"
    #       "DISPLAY=fake"
    #     ];
    #   };
    # };

    hm.systemd.user.services.ssh-agent = mkIf (config.programs.ssh.enable && hmConfig.services.ssh-agent.enable) {
      # Service.ExecStart = lib.mkForce "SSH_ASKPASS_REQUIRE=\"prefer\" SSH_ASKPASS=\"${askpass}\" ${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
      Service = {
        ExecStartPost = "${pkgs.writeShellScript "ssh-agent-post" ''
          export SSH_ASKPASS_REQUIRE=prefer
          export SSH_ASKPASS="${askpass}"
          export DISPLAY=fake
          export "$(systemctl --user show-environment | grep '^XDG_RUNTIME_DIR=')"
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"

          ${lib.concatStringsSep "\n" (map (key: "${pkgs.openssh}/bin/ssh-add ${key.private} || true") (builtins.attrValues ssh."${config.users.host}" ))}
        ''} &";
        Environment = [
          "PATH=${lib.makeBinPath (with pkgs; [
            coreutils
            systemd
            gnugrep
          ])}"
        ];
      };
    };

    os.nixpkgs.overlays = [
      (_final: prev: {
        get-password = prev.writeShellScriptBin "get-password" ''
          exact_option=false

          for arg in "$@"; do
            if [[ "$arg" == "--exact" ]]; then
              exact_option=true
              break
            fi
          done

          if $exact_option; then
            ${prev.bitwarden-cli}/bin/bw list items --search "$1" --session $(cat ~/.bw_session) | ${prev.jq}/bin/jq -r ".[] | select(.name==\"$1\") | .login.password" -e
          else
            ${prev.bitwarden-cli}/bin/bw list items --search "$1" --session $(cat ~/.bw_session) | ${prev.jq}/bin/jq -r '.[0].login.password' -e
          fi
        '';
      })
    ];

    os.environment.systemPackages = mkIf config.secrets.enable [
      pkgs.bitwarden-cli
      pkgs.get-password
    ];
  };
}
