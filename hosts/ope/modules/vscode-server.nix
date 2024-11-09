{
  config,
  utils,
  ...
}: let
  inherit (utils) getHostname;
in {
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
    host = getHostname "ope.wg_private";
    port = 58846;
  };

  insecure.allowed = [
    "nodejs-16.20.2"
  ];

  networking.allowedPorts.tcp."58846" = [(getHostname "ope.wg_private")];
}
