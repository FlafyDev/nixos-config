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

  networking.allowedPorts.tcp."58846" = [ "ope.wg_private.flafy.me" ];
}
