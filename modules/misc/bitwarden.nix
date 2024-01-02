{
  lib,
  config,
  pkgs,
  hmConfig,
  ...
}: let
  cfg = config.bitwarden;
  inherit (lib) mkEnableOption mkIf;
  askpass = toString (pkgs.writeShellScript "ask-password" ''
    key_name="$1"
    key_name="''${key_name##*/}"
    key_name="''${key_name%%:*}"
    key_name="''${key_name//\'/}"

    echo "$key_name" >&2
    pass=$(get-password "ssh $key_name" --exact)

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

    hm.systemd.user.services.ssh-agent = mkIf hmConfig.services.ssh-agent.enable {
      # Service.ExecStart = lib.mkForce "SSH_ASKPASS_REQUIRE=\"prefer\" SSH_ASKPASS=\"${askpass}\" ${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
      Service = {
        Environment = [
          "SSH_ASKPASS_REQUIRE=prefer"
          "SSH_ASKPASS=${askpass}"
          "DISPLAY=fake"
        ];
      };
    };

    os.environment.systemPackages = let
      getPassword = pkgs.writeShellScriptBin "get-password" ''
        exact_option=false

        for arg in "$@"; do
          if [[ "$arg" == "--exact" ]]; then
            exact_option=true
            break
          fi
        done

        if $exact_option; then
          ${pkgs.bitwarden-cli}/bin/bw list items --search "$1" --session $(cat ~/.bw_session) | ${pkgs.jq}/bin/jq -r ".[] | select(.name==\"$1\") | .login.password" -e
        else
          ${pkgs.bitwarden-cli}/bin/bw list items --search "$1" --session $(cat ~/.bw_session) | ${pkgs.jq}/bin/jq -r '.[0].login.password' -e
        fi
      '';
    in
      mkIf config.secrets.enable [
        pkgs.bitwarden-cli
        getPassword
      ];
  };
}
