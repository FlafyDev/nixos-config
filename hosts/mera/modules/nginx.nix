{
  osConfig,
  config,
  utils,
  lib,
  secrets,
  ...
}: let
  inherit (utils) resolveHostname getHostname domains;
  inherit (lib) mkOption types mkDefault;
in {
  networking.vpnNamespace.vpn.ports.tcp = ["80" "443"];

  os.environment.persistence = {
    "/persist2" = {
      directories = [
        {
          directory = "/var/lib/acme";
          user = "root";
          group = "root";
        }
      ];
    };
  };

  containers.maneVpn2 = {
    bindMounts = {
      "/var/lib/acme".isReadOnly = false;
      ${secrets.porkbun}.isReadOnly = true;
    };
    config.os = {
      options.services.nginx.virtualHosts = mkOption {
        type = types.attrsOf (types.submodule (_: {
          # TODO: Make a new option for this.
          sslCertificate = mkDefault "/var/lib/acme/_.${domains.personal}/fullchain.pem";
          sslCertificateKey = mkDefault "/var/lib/acme/_.${domains.personal}/key.pem";
        }));
      };
      config = {
        # security.acme = {
        #   acceptTerms = true;
        #   defaults.email = "flafyarazi@gmail.com";
        #   certs."flafy.dev" = {
        #     domain = "flafy.dev";
        #     group = "nginx";
        #     dnsProvider = "porkbun";
        #     # env file with PORKBUN_SECRET_API_KEY PORKBUN_API_KEY
        #     credentialsFile = secrets.porkbun;
        #   };
        #   certs."_.flafy.dev" = {
        #     domain = "*.flafy.dev";
        #     group = "nginx";
        #     dnsProvider = "porkbun";
        #     # env file with PORKBUN_SECRET_API_KEY PORKBUN_API_KEY
        #     credentialsFile = secrets.porkbun;
        #   };
        # };

        services.nginx = {
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
    };
  };
}
