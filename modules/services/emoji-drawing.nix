{
  inputs,
  config,
  lib,
  osConfig,
  pkgs,
  osOptions,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.services.emojiDrawing;
in {
  # TODO: Tunnel options
  options.services.emojiDrawing = mkOption {
    type = types.submodule (_: {
      options =
        (inputs.emoji-drawing.nixosModules.default {
          inherit pkgs lib;
          config = {};
        })
        .options
        .services
        .emojiDrawing;
    });
    default = {enable = false;};
    description = "Emoji Drawing service options.";
  };

  config = {
    users.groups = [osConfig.services.emojiDrawing.user];
    inputs = {
      emoji-drawing.url = "github:flafydev/emoji-drawing";
    };
    osModules = [inputs.emoji-drawing.nixosModules.default];
    os.services.emojiDrawing = cfg;
  };
}
