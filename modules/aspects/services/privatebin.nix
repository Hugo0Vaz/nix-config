{ lib, ... }:
{
  flake.modules.nixos.privatebin =
    { ... }:
    {
      services.privatebin = {
        enable = true;

        enableNginx = true;
        virtualHost = "pastebin.hugovaz.dev";

        settings = {
          main = {
            name = "PrivateBin";
            discussion = false;
            opendiscussion = false;
            password = true;
            fileupload = false;
            burnafterreadingselected = true;
            defaultformatter = "plaintext";
          };

          expire.default = "1week";
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = lib.mkDefault "admin@hugovaz.dev";
      };

      services.nginx = {
        # The PrivateBin module will create the vhost when enableNginx = true;
        # we only add HTTPS + some recommended defaults.
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        virtualHosts."pastebin.hugovaz.dev" = {
          enableACME = true;
          forceSSL = true;
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
