{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.fish;
in {
  options.programs.fish = {
    enable = mkEnableOption "fish";
  };

  config = mkIf cfg.enable {
    sys = {
      users.defaultUserShell = pkgs.fish;
      environment.pathsToLink = ["/share/fish"];
      programs.fish.enable = true;
    };

    home = {
      programs.nix-index.enableFishIntegration = true;
      # programs.starship.enableFishIntegration = true;
      # programs.direnv.enableFishIntegration = true;

      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
          fish_vi_key_bindings
        '';
        plugins =
          map (plugin: {
            name = plugin.pname;
            inherit (plugin) src;
          }) (with pkgs.fishPlugins; [
            pure
            autopair
            done
          ]);
        shellAliases = {
          ll = "${pkgs.exa}/bin/exa -la";
          ls = "${pkgs.exa}/bin/exa";
          batp = "${pkgs.bat}/bin/bat -P";
        };
      };
    };
  };
}
