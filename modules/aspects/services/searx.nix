{ lib, config, ... }:
{
  flake.modules.nixos.searx =
    { config, ... }:
    {
      services.searx = {
        enable = true;
        configureNginx = true;
        redisCreateLocally = true;
        domain = "searx.hugovaz.dev";
        environmentFile = config.sops.secrets.searx_env.path;
        settings = {
          use_default_settings = true;
          general.instance_name = "SearxNG";
          search.safe_search = 0;
          search.autocomplete = "google";
          search.formats = ["html" "json"];
          server.secret_key = "$SEARXNG_SECRET";
        };
      };

      sops.secrets.searx_env = {
        owner = "searx";
        group = "searx";
        mode = "0400";
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = lib.mkDefault "admin@hugovaz.dev";
      };

      services.nginx = {
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        virtualHosts."searx.hugovaz.dev" = {
          enableACME = true;
          forceSSL = true;
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
