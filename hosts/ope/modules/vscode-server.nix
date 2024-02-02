{config, ...}: {
  os.services.openvscode-server = {
    enable = true;
    user = config.users.main;
    # This is going through a private wireguard interface(named "private"). So no need for a token.
    withoutConnectionToken = true;
    # package = pkgs.openvscode-server.overrideAttrs (old: {
    #   patches =
    #     (old.patches or [])
    #     ++ [
    #       ../mera/temppatch.patch
    #     ];
    # });
    host = "ope.wg_private.flafy.me";
    port = 58846;
  };

  os.nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];

  # networking.vpsForwarding.udp."58846" = true;
  networking.allowedPorts.tcp."58846" = [ "ope.wg_private.flafy.me" ];
  # networking.allowedPorts.tcp."58846-58847" = [ "ope.wg_private.flafy.me" ];
  # networking.allowedPorts.tcp."{80,443}" = [ "ope.wg_private.flafy.me" ];

  # os.networking.firewall.allowedTCPPorts = [58846];

  # Allows the port in the firewall and tells the vps machine to forward the port from from this machine. 
  # vpsForwarding.udp = [ ]
  # vpsForwarding.tcp = [ 58846 ];

  # TODO: config to tunnel port to mane
}
