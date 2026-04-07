{ lib, ... }:
{
  flake.modules.nixos.couchdb-obsidian-livesync =
    { config, pkgs, ... }:
    {
      sops.secrets.couchdb_admin_password = {
        mode = "0400";
      };

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

      sops.templates.couchdb_livesync_env = {
        mode = "0400";
        content = ''
          COUCHDB_ADMIN_USER=admin
          COUCHDB_ADMIN_PASSWORD=${config.sops.placeholder.couchdb_admin_password}
          COUCHDB_DB=obsidian
          COUCHDB_USER=obsidian
          COUCHDB_PASSWORD=${config.sops.placeholder.couchdb_livesync_password}
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

      systemd.services.couchdb-obsidian-livesync-bootstrap = {
        description = "Bootstrap CouchDB for Obsidian LiveSync";
        after = [ "couchdb.service" ];
        requires = [ "couchdb.service" ];
        wantedBy = [ "multi-user.target" ];

        path = [
          pkgs.coreutils
          pkgs.curl
          pkgs.jq
        ];

        serviceConfig = {
          Type = "oneshot";
          EnvironmentFile = config.sops.templates.couchdb_livesync_env.path;
        };

        script = ''
          set -euo pipefail

          : "''${COUCHDB_ADMIN_USER:?Missing COUCHDB_ADMIN_USER}"
          : "''${COUCHDB_ADMIN_PASSWORD:?Missing COUCHDB_ADMIN_PASSWORD}"
          : "''${COUCHDB_DB:?Missing COUCHDB_DB}"
          : "''${COUCHDB_USER:?Missing COUCHDB_USER}"
          : "''${COUCHDB_PASSWORD:?Missing COUCHDB_PASSWORD}"

          if [ -z "''${COUCHDB_ADMIN_PASSWORD}" ] || [ "''${COUCHDB_ADMIN_PASSWORD}" = "CHANGEME" ]; then
            echo "Refusing to bootstrap with COUCHDB_ADMIN_PASSWORD=CHANGEME" >&2
            exit 1
          fi

          if [ -z "''${COUCHDB_PASSWORD}" ] || [ "''${COUCHDB_PASSWORD}" = "CHANGEME" ]; then
            echo "Refusing to bootstrap with COUCHDB_PASSWORD=CHANGEME" >&2
            exit 1
          fi

          base="http://127.0.0.1:5984"
          boot_file="/var/lib/couchdb/obsidian-livesync.bootstrapped"

          if [ -f "$boot_file" ]; then
            echo "Already bootstrapped: $boot_file"
            exit 0
          fi

          for _ in $(seq 1 60); do
            if curl -fsS "$base/_up" >/dev/null; then
              break
            fi
            sleep 1
          done

          auth=(-u "$COUCHDB_ADMIN_USER:$COUCHDB_ADMIN_PASSWORD")

          db_code=$(curl -sS -o /dev/null -w '%{http_code}' "''${auth[@]}" -X PUT "$base/$COUCHDB_DB" || true)
          if [ "$db_code" != "201" ] && [ "$db_code" != "202" ] && [ "$db_code" != "412" ]; then
            echo "Failed to create DB '$COUCHDB_DB' (HTTP $db_code)" >&2
            exit 1
          fi

          user_id="org.couchdb.user:$COUCHDB_USER"
          existing=$(curl -sS "''${auth[@]}" "$base/_users/$user_id" || true)

          if echo "$existing" | jq -e '.error == "not_found"' >/dev/null 2>&1; then
            user_rev=""
            user_roles='[]'
          else
            user_rev=$(echo "$existing" | jq -r '._rev // empty')
            user_roles=$(echo "$existing" | jq -c '.roles // []')
          fi

          user_doc=$(jq -n \
            --arg name "$COUCHDB_USER" \
            --arg pass "$COUCHDB_PASSWORD" \
            --arg rev "$user_rev" \
            --argjson roles "$user_roles" \
            '({name: $name, password: $pass, roles: $roles, type: "user"} + ( ($rev | length) > 0 ? {_rev: $rev} : {} ))'
          )

          curl -fsS "''${auth[@]}" \
            -X PUT "$base/_users/$user_id" \
            -H 'Content-Type: application/json' \
            --data "$user_doc" \
            >/dev/null

          security_doc=$(jq -n --arg user "$COUCHDB_USER" '{admins:{names:[],roles:[]},members:{names:[$user],roles:[]}}')
          curl -fsS "''${auth[@]}" \
            -X PUT "$base/$COUCHDB_DB/_security" \
            -H 'Content-Type: application/json' \
            --data "$security_doc" \
            >/dev/null

          install -m 0644 /dev/null "$boot_file"
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
              if (!-f /var/lib/couchdb/obsidian-livesync.bootstrapped) { return 503; }
              proxy_read_timeout 3600s;
              proxy_send_timeout 3600s;
              proxy_buffering off;
            '';
          };
        };
      };
    };
}
