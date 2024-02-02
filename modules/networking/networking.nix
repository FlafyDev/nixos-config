{
  lib,
  ...
}: let
  inherit (lib) mkOption types mkEnableOption;
in {
  options.networking = {
    enable = mkEnableOption "nftables";
  };
}
