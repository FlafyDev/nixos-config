{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.bitwarden;
  inherit (lib) mkEnableOption mkIf;
in {
  options.bitwarden = {
    enable = mkEnableOption "bitwarden";
  };

  config = mkIf cfg.enable {
    secrets.autoBitwardenSession.enable = mkIf config.secrets.enable true;

    os.environment.systemPackages = let
      getPassword = pkgs.writeShellScriptBin "get-password" ''
        ${pkgs.bitwarden-cli}/bin/bw list items --search $1 --session $(cat ~/.bw_session) | ${pkgs.jq}/bin/jq -r '.[0].login.password'
      '';
    in
      mkIf config.secrets.enable [
        pkgs.bitwarden-cli
        getPassword
      ];
  };
}
