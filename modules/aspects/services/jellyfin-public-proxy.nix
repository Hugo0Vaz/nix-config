{ lib, ... }:
let
  virtualHost = "jellyfin.hugovaz.dev";
  jellyfinUpstream = "http://nixos-workstation.taildff3e4.ts.net:8096";
in
{
  flake.modules.nixos.jellyfinPublicProxy =
    { ... }:
    {
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

        virtualHosts.${virtualHost} = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            proxyPass = jellyfinUpstream;
            proxyWebsockets = true;
            extraConfig = ''
              proxy_buffering off;
            '';
          };
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
