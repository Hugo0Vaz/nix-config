{ lib, ... }:
{
  flake.modules.nixos.docsdog =
    { config, pkgs, inputs, ... }:
    let
      docsdogSite = inputs.docsdog.packages.${pkgs.stdenv.hostPlatform.system}.docs;
    in
    {
      security.acme = {
        acceptTerms = true;
        defaults.email = lib.mkDefault "admin@hugovaz.dev";
      };

      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        virtualHosts."docsdog.hugovaz.dev" = {
          enableACME = true;
          forceSSL = true;
          root = docsdogSite;
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
