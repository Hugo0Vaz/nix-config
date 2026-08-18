{ lib, ... }:
{
  flake.modules.nixos.blog =
    { config, pkgs, inputs, ... }:
    let
      blogPackages = inputs.blog.packages.${pkgs.stdenv.hostPlatform.system};
      blogSite = blogPackages.default;
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

        virtualHosts."hugovaz.dev" = {
          enableACME = true;
          forceSSL = true;
          root = blogSite;
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
