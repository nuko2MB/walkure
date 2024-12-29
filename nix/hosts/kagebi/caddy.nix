{
  inputs,
  config,
  pkgs,
  ...
}:
{
  age.secrets.caddy.rekeyFile = inputs.self + "/secrets/caddy.env.age";

  networking.firewall.allowedTCPPorts = [
    443
    80
  ];

  services.caddy = {
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/porkbun@v0.2.1" ];
      hash = "sha256-oizWuPXI0M9ngBCt/iEXWt+/33wpKlCs1yBPKnzFhRY=";
    };

    enable = true;
    # logFormat = "level INFO";
    extraConfig = ''
      *.{$DOMAIN} {
        tls {
          dns porkbun {
            api_key {env.PORKBUN_API_KEY}
            api_secret_key {env.PORKBUN_API_KEY_SECRET}
          }
        }
        
        @vikunja host vikunja.{$DOMAIN}
        handle @vikunja {
              reverse_proxy http://localhost:3456
         }

        @abs host abs.{$DOMAIN}
        handle @abs {
          reverse_proxy http://localhost:6543
        }

        @adguard host adguard.{$DOMAIN}
        handle @adguard {
          reverse_proxy http://localhost:3000
        }
          
      }
    '';
  };

  systemd.services.caddy = {
    serviceConfig = {
      EnvironmentFile = [
        config.age.secrets."caddy".path
      ];
    };
  };
}
