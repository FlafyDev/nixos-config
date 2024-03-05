{
  osConfig,
  config,
  utils,
  lib,
  ...
}: let
  inherit (utils) resolveHostname getHostname domains;
  inherit (lib) mkOption types mkDefault;
in {
  # networking.vpsForwarding.mane.tcp = ["80" "443"];
  os = {options, ...}: {
    options.services.nginx.virtualHosts = mkOption {
      type = types.attrsOf (types.submodule (_: {
        # TODO: Make a new option for this.
        sslCertificate = mkDefault "/var/lib/acme/_.${domains.personal}/fullchain.pem";
        sslCertificateKey = mkDefault "/var/lib/acme/_.${domains.personal}/key.pem";
      }));
    };

    config.services.nginx = {
      enable = true;
      defaultListen = [
        {
          addr = resolveHostname "mera.wg_vps";
          ssl = true;
          port = 443;
        }
        # {
        #   addr = resolveHostname "mera.wg_vps";
        #   ssl = false;
        #   port = 80;
        # }
      ];
      virtualHosts = {
        ${domains.personal} = {
          addSSL = true;
          sslCertificate = "/var/lib/acme/${domains.personal}/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/${domains.personal}/key.pem";
          serverAliases = [domains.personal "www.${domains.personal}"];
          locations."/" = {
            proxyPass = "http://localhost:40004";
          };
        };
        "emoji.${domains.personal}" = {
          addSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:40002";
          };
          locations."/api" = {
            proxyPass = "http://localhost:40003";
          };
        };
        # "flafy.me" = {
        #   listen = [
        #     {
        #       addr = resolveHostname "mera.wg_vps";
        #       ssl = false;
        #       port = 80;
        #     }
        #   ];
        #   extraConfig = ''
        #     return 301 $scheme://${domains.personal};
        #   '';
        # };
        # "~^(?<subdomain>.+)\.flafy\.me$" = {
        #   listen = [
        #     {
        #       addr = resolveHostname "mera.wg_vps";
        #       ssl = false;
        #       port = 80;
        #     }
        #   ];
        #   extraConfig = ''
        #     if ($subdomain) {
        #       set $new_domain "''${subdomain}.${domains.personal}";
        #       return 301 https://$new_domain;
        #     }
        #     return 301 https://${domains.personal};
        #   '';
        # };
      };
    };
  };
}
