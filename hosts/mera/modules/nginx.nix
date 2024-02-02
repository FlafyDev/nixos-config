{
  osConfig,
  resolveHostname,
  ...
}: {
  networking.vpsForwarding.mane.tcp = ["80" "443"];
  os.services.nginx = let
    sslConfig = {
      sslCertificate = osConfig.age.secrets.flafy_me-cert.path;
      sslCertificateKey = osConfig.age.secrets.flafy_me-key.path;
      addSSL = true;
    };
    domain = "flafy.me";
  in {
    enable = true;
    defaultListen = [
      {
        addr = resolveHostname "mera.wg_vps.flafy.me";
        ssl = true;
        port = 443;
      }
      {
        addr = resolveHostname "mera.wg_vps.flafy.me";
        ssl = false;
        port = 80;
      }
    ];
    virtualHosts = {
      ${domain} =
        sslConfig
        // {
          serverAliases = [domain "www.${domain}"];
          locations."/" = {
            proxyPass = "http://localhost:40004";
          };
        };
      "emoji.${domain}" =
        sslConfig
        // {
          locations."/" = {
            proxyPass = "http://localhost:40002";
          };
          locations."/api" = {
            proxyPass = "http://localhost:40003";
          };
        };
    };
  };
}
