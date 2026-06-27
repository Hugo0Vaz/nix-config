{ lib, ... }:
{
  flake.modules.nixos.vaultwarden =
    { config, ... }:
    {
      services.vaultwarden = {
        enable = true;

        # Keep Vaultwarden private; expose only via Nginx.
        config = {
          DOMAIN = "https://vaultwarden.hugovaz.dev";

          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;

          WEBSOCKET_ENABLED = true;

          # Turn this off after creating your first user.
          SIGNUPS_ALLOWED = false;

          SHOW_PASSWORD_HINT = false;
        };

        # Put secrets (ADMIN_TOKEN, SMTP_PASSWORD, etc.) in sops, not the Nix store.
        environmentFile = config.sops.secrets.vaultwarden_env.path;
      };

      sops.secrets.vaultwarden_env = {
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0400";
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = lib.mkDefault "admin@hugovaz.dev";
      };

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        clientMaxBodySize = "128m";

        virtualHosts."vaultwarden.hugovaz.dev" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:8222";
            proxyWebsockets = true;
          };
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
