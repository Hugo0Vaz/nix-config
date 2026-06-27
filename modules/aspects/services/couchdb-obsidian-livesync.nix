{ lib, ... }:
{
  flake.modules.nixos.couchdb-obsidian-livesync =
    { config, pkgs, ... }:
    {
      sops.secrets.couchdb_admin_password = {
        mode = "0400";
      };

      # Password for the non-admin user used by Obsidian LiveSync.
      # Add `couchdb_livesync_password` to `secrets/secrets.yaml` via `sops`.
      sops.secrets.couchdb_livesync_password = {
        mode = "0400";
      };

      sops.templates.couchdb_admin_ini = {
        owner = "couchdb";
        group = "couchdb";
        mode = "0400";
        restartUnits = [ "couchdb.service" ];
        content = ''
          [admins]
          admin = ${config.sops.placeholder.couchdb_admin_password}
        '';
      };

      services.couchdb = {
        enable = true;

        bindAddress = "127.0.0.1";

        # CouchDB 3.x can refuse to start without an admin.
        # Provide the admin config via sops (not in the Nix store).
        extraConfigFiles = [
          config.sops.templates.couchdb_admin_ini.path
        ];

        extraConfig = {
          chttpd = {
            require_valid_user = true;
            enable_cors = true;
          };

          cors = {
            # Obsidian desktop uses a custom app:// origin; mobile often uses capacitor://.
            origins = "app://obsidian.md,capacitor://localhost,http://localhost";
            credentials = true;
            methods = "GET, PUT, POST, HEAD, DELETE";
            headers = "accept, authorization, content-type, origin, referer";
          };
        };
      };

      environment.systemPackages = [
        (import ../_scripts/couchdb-obsidian-livesync-bootstrap.nix {
          inherit pkgs;
          adminPassFile = config.sops.secrets.couchdb_admin_password.path;
          userPassFile = config.sops.secrets.couchdb_livesync_password.path;
          baseUrl = "http://127.0.0.1:5984";
          db = "obsidian";
          user = "obsidian";
          adminUser = "admin";
        })
      ];

      # CouchDB persists runtime config into `services.couchdb.configFile` (local.ini),
      # including a hashed admin password. Since that file is loaded last, it can
      # override our sops-provided admin password and make logins fail after a
      # rotation.
      #
      # We strip the `[admins]` section from the runtime config on each start so
      # the admin password is always sourced from sops.
      systemd.services.couchdb = {
        preStart = lib.mkAfter ''
          cfg_file="${config.services.couchdb.configFile}"
          tmp_file="${config.services.couchdb.configFile}.tmp"

          if [ -f "$cfg_file" ]; then
            ${pkgs.gawk}/bin/awk '
              BEGIN { skip = 0 }
              /^\[admins\]$/ { skip = 1; next }
              skip && /^\[/ { skip = 0 }
              !skip { print }
            ' "$cfg_file" >"$tmp_file"

            ${pkgs.coreutils}/bin/mv "$tmp_file" "$cfg_file"
          fi
        '';
      };

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        virtualHosts."couchdb.hugovaz.dev" = {
          enableACME = true;
          forceSSL = true;

          extraConfig = ''
            client_max_body_size 256m;
          '';

          locations."/" = {
            proxyPass = "http://127.0.0.1:5984";
            extraConfig = ''
              proxy_read_timeout 3600s;
              proxy_send_timeout 3600s;
              proxy_buffering off;
            '';
          };
        };
      };
    };
}
