{ lib, ... }:
{
  flake.modules.nixos.blog =
    { config, pkgs, inputs, ... }:
    let
      blogPackages = inputs.blog.packages.${pkgs.stdenv.hostPlatform.system};
      blogSite = blogPackages.default.overrideAttrs (old: {
        nativeBuildInputs = [ pkgs.pnpm_9 ] ++ builtins.filter (x: (x.pname or "") != "pnpm") (old.nativeBuildInputs or [ ]);
        pnpmDeps = pkgs.fetchPnpmDeps.override { pnpm = pkgs.pnpm_9; } {
          inherit (old) pname version src;
          fetcherVersion = 3;
          hash = "sha256-ZF7CLnQkVkpv4Xy9SgrPlkSB3NejoUZ0jhRmPrQEJGM=";
        };
      });
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
