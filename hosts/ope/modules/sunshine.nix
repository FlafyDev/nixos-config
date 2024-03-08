{utils, ...}: let
  inherit (utils) getHostname;
in {
  # networking.vpnNamespace.vpn.ports = {
  #   tcp = ["47984" "47989" "48010"];
  #   udp = ["47998-48000" "48002" "48010"];
  # };

  programs.sunshine = {
    enable = true;
    hyprlandIntegration.enable = true;
  };

  # networking.vpsForwarding.mane.tcp = ["47984" "47989" "48010"];
  # networking.vpsForwarding.mane.udp = ["47998-48000" "48002" "48010"];

  # networking.allowedPorts.tcp."47990,47984,47989,48010" = [(getHostname "ope.wg_private")];
  # networking.allowedPorts.udp."47998-48000,48002,48010" = [(getHostname "ope.wg_private")];
}
