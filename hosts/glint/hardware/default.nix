{
  pkgs,
  osConfig,
  lib,
  inputs,
  config,
  ...
}: {
  osModules = [
    ./hardware-configuration.nix
  ];

  os.boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
