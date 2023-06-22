{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.games;
in {
  options.games = {
    enable = mkEnableOption "games";
  };

  config = mkIf cfg.enable {
    unfree.allowed = [
      "steam"
      "steam-original"
      "steam-run"
    ];
    os.programs.steam = {
      enable = true;
      # remotePlay.openFirewall = true;
      # dedicatedServer.openFirewall = true;
    };
  };
}
