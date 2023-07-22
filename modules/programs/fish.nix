{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.fish;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.fish = {
    enable = mkEnableOption "fish";
  };

  config = mkIf cfg.enable {
    os = {
      users.defaultUserShell = pkgs.fish;
      environment.pathsToLink = ["/share/fish"];
      programs.fish.enable = true;
    };

    hm = {
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
      };
    };
  };
}
