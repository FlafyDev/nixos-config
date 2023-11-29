{
  inputs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.games.services.minecraft;
in {
  options.games.services.minecraft = {
    enable = mkEnableOption "minecraft";
  };

  config = mkMerge [
    {
      inputs.nix-minecraft = {
        url = "github:infinidoge/nix-minecraft";
      };
    }
    (
      mkIf cfg.enable {
        osModules = [
          inputs.nix-minecraft.nixosModules.minecraft-servers
        ];
        os.services.minecraft-servers = {
          enable = true;
          eula = true;
          servers.vanilla = {
            enable = true;
            jvmOpts = "-Xmx512M"; # Avoid OOM
            package = pkgs.vanillaServers.vanilla-1_20_2;
            serverProperties = {
              server-port = 25565;
              level-type = "flat"; # Make the test lighter
              max-players = 10;
            };
          };
        };
      }
    )
  ];
}
