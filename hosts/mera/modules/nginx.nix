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

  networking.forwardPorts = {
    "10.0.0.15" = {
      tcp = ["5556"];
      masquerade = true;
    };
  };

  containers.maneVpn2 = {
    bindMounts = {
      "/var/lib/acme".isReadOnly = false;
      "/persist".isReadOnly = false;
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
        # systemd.services.acme.restartIfChanged = false;
        security.acme = {
          acceptTerms = true;
          defaults.email = "flafyarazi@gmail.com";
          certs."flafy.dev" = {
            domain = "flafy.dev";
            group = "nginx";
            dnsProvider = "porkbun";
            # env file with PORKBUN_SECRET_API_KEY PORKBUN_API_KEY
            credentialsFile = secrets.porkbun;
          };
          certs."_.flafy.dev" = {
            domain = "*.flafy.dev";
            group = "nginx";
            dnsProvider = "porkbun";
            # env file with PORKBUN_SECRET_API_KEY PORKBUN_API_KEY
            credentialsFile = secrets.porkbun;
          };
        };

        services.nginx = {
          enable = true;
          defaultListen = [
            {
              addr = resolveHostname "mera.wg_vps";
              ssl = true;
              port = 443;
            }
          ];
          virtualHosts = {
            ${domains.personal} = {
              addSSL = true;
              sslCertificate = "/var/lib/acme/${domains.personal}/fullchain.pem";
              sslCertificateKey = "/var/lib/acme/${domains.personal}/key.pem";
              locations."/" = {
                root = "/persist/temp-site";
                index = "index.html";
                tryFiles = "$uri $uri/ =404";
              };
            };
            "www.${domains.personal}" = {
              addSSL = true;
              locations."/" = {
                root = "/persist/temp-site";
                index = "index.html";
                tryFiles = "$uri $uri/ =404";
              };
            };
            "sans.${domains.personal}" = {
              addSSL = true;
              locations."/" = {
                proxyPass = "http://127.0.0.1:40004";
              };
            };
            "showcase.${domains.personal}" = {
              addSSL = true;
              locations."/" = {
                proxyPass = "http://127.0.0.1:8080";
              };
            };
            "emoji.${domains.personal}" = {
              addSSL = true;
              locations."/" = {
                proxyPass = "http://127.0.0.1:40002";
              };
              locations."/api" = {
                proxyPass = "http://127.0.0.1:40003";
              };
            };
            "test.${domains.personal}" = {
              addSSL = true;
              locations."/" = {
                proxyPass = "http://10.10.15.10:5556";
              };
            };
            "fallback-https" = {
              addSSL = true;
              default = true;
              serverName = "_";
              locations."/" = {
                return = "301 https://flafy.dev$request_uri";
              };
            };
            "fallback-http" = {
              listen = [
                {
                  addr = resolveHostname "mera.wg_vps";
                  ssl = false;
                  port = 80;
                }
              ];
              serverName = "_";
              locations."/" = {
                return = "301 https://$host$request_uri";
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
