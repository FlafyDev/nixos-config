{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.vscode;
  inherit (lib) mkOption mkEnableOption mkIf types;
  inherit (builtins) fetchurl;
in {
  options.programs.vscode = {
    enable = mkEnableOption "vscode";
    package = mkOption {
      type = with types; package;
      default = pkgs.vscodium.overrideAttrs (old: {
        src = fetchurl {
          url = "https://github.com/FlafyDev/vscodium/releases/download/1.79.2.23182/VSCodium-linux-x64-1.79.2.23182.tar.gz";
          sha256 = "1vcg3jzjwlmzv0dh45521n1q0fapf7j8ca9l2ccm1dpphxr2pipj";
        };
      });
    };
  };

  config = mkIf cfg.enable {
    os.environment.systemPackages = [
      (pkgs.writeShellScriptBin "code" ''
        export PATH=$PATH:${lib.makeBinPath (with pkgs; [
          nil
        ])}
        ${cfg.package}/bin/codium -n $@
      '')
    ];
  };
}
