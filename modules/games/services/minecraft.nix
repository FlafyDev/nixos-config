{
  inputs,
  lib,
  config,
  elib,
  pkgs,
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
        users.groups = ["minecraft"];
        osModules = [
          inputs.nix-minecraft.nixosModules.minecraft-servers
        ];
        os.services.minecraft-servers = {
          enable = true;
          eula = true;
          servers = {
            # dawncraft = {
            #   enable = true;
            #   jvmOpts = "-Xmx6G"; # Avoid OOM
            #   # package = pkgs.fabricServers.fabric-1_17_1.override { loaderVersion = "0.15.1"; };
            #   package = (elib.flLPkgs' inputs.nix-minecraft ["fabricServers" "fabric-1_17_1"]).override {loaderVersion = "0.15.0";};
            #   symlinks = {
            #     "mods" = "/srv/minecraft/mods";
            #   };
            #   serverProperties = {
            #     require-resource-pack = true;
            #     enable-command-block = true;
            #     server-port = 25565;
            #     max-players = 10;
            #   };
            # };

            fabric-server = {
              enable = true;
              jvmOpts = "-Xmx4G";
              package = inputs.nix-minecraft.legacyPackages.${pkgs.system}.fabricServers.fabric-1_20_4;
              serverProperties = {
                require-resource-pack = false;
                enable-command-block = true;
                server-port = 25565;
                max-players = 10;
              };
            };

            # datapacktests4 = {
            #   enable = true;
            #   jvmOpts = "-Xmx4G"; # Avoid OOM
            #   package = elib.flLPkgs' inputs.nix-minecraft ["paperServers" "paper-1_20_4"];
            #   serverProperties = {
            #     require-resource-pack = false;
            #     enable-command-block = true;
            #     server-port = 25565;
            #     max-players = 10;
            #   };
            # };

            # map = {
            #   enable = true;
            #   jvmOpts = "-Xmx10G"; # Avoid OOM
            #   # package = pkgs.fabricServers.fabric-1_17_1.override { loaderVersion = "0.15.1"; };
            #   package = (elib.flLPkgs' inputs.nix-minecraft ["fabricServers" "fabric-1_17_1"]).override {loaderVersion = "0.15.0";};
            #   symlinks = {
            #     "mods" = "/srv/minecraft/mods";
            #   };
            #   serverProperties = {
            #     require-resource-pack = true;
            #     enable-command-block = true;
            #     server-port = 25565;
            #     max-players = 10;
            #   };
            # };
          };
        };
      }
    )
  ];
}
