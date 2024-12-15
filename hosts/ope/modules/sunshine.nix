{utils, ...}: let
  inherit (utils) getHostname;
in {

  # networking.allowedPorts.tcp."47984,47989,48010,47990,5557" = ["*"];
  # networking.allowedPorts.udp."47998-48000" = ["*"];
  # networking.allowedPorts.udp."48002,48010" = ["*"];
  # networking.vpnNamespace.vpn.ports = {
  #   tcp = ["47984" "47989" "48010" "47990" "5557"];
  #   udp = ["47998-48000" "48002" "48010"];
  # };

  programs.sunshine = {
    enable = false;
    hyprlandIntegration.enable = false;
  };

  # networking.vpsForwarding.mane.tcp = ["47984" "47989" "48010"];
  # networking.vpsForwarding.mane.udp = ["47998-48000" "48002" "48010"];

  # networking.allowedPorts.tcp."47990,47984,47989,48010" = [(getHostname "ope.wg_private")];
  # networking.allowedPorts.udp."47998-48000,48002,48010" = [(getHostname "ope.wg_private")];
}
