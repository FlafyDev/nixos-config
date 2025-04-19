# TODO: I'm making this its own module so in the future I'll make the vscode more declarative.
{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.code-server;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.code-server = {
    enable = mkEnableOption "code-server";
  };

  config = mkIf cfg.enable {
    os.environment.systemPackages = [
      pkgs.code-server
    ];
  };
}