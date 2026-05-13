{
  flake.modules.nixos.cli-tools =
    { config, lib, pkgs, ... }:

    let
      cfg = config.services.myLaravelApp;
      phpPackage = pkgs.php83.buildEnv {
        extensions = ({ enabled, all }: enabled ++ (with all; [
          pdo pdo_pgsql mbstring curl openssl tokenizer
          ctype fileinfo redis intl
        ]));
      };
    in
    {
      options.services.myLaravelApp = {
        enable = lib.mkEnableOption "My Laravel App";

        repoUrl = lib.mkOption {
          type = lib.types.str;
          description = "Git repository URL to clone/pull";
          example = "https://github.com/your-org/your-laravel-repo.git";
        };

        branch = lib.mkOption {
          type = lib.types.str;
          default = "main";
          description = "Git branch to deploy";
        };

        appDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/www/laravel";
          description = "Directory where the app lives on disk";
        };

        domain = lib.mkOption {
          type = lib.types.str;
          description = "Domain name for the virtual host";
          example = "myapp.example.com";
        };

        envFile = lib.mkOption {
          type = lib.types.str;
          description = "Path to the .env file (managed outside Nix, e.g. via sops-nix)";
          default = "/run/secrets/laravel-env";
        };
      };

      config = lib.mkIf cfg.enable {

        # ── Users ──────────────────────────────────────────────────────────────
        users.users.laravel = {
          isSystemUser = true;
          group = "laravel";
          home = cfg.appDir;
        };
        users.groups.laravel = {};

        # ── Nginx ──────────────────────────────────────────────────────────────
        services.nginx = {
          enable = true;
          virtualHosts.${cfg.domain} = {
            root = "${cfg.appDir}/public";
            extraConfig = ''
              index index.php;
              location / {
                try_files $uri $uri/ /index.php?$query_string;
              }
              location ~ \.php$ {
                fastcgi_pass unix:${config.services.phpfpm.pools.laravel.socket};
                fastcgi_index index.php;
                include ${pkgs.nginx}/conf/fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              }
              location ~ /\.ht { deny all; }
            '';
          };
        };

        # ── PHP-FPM ────────────────────────────────────────────────────────────
        services.phpfpm.pools.laravel = {
          user = "laravel";
          group = "laravel";
          inherit phpPackage;
          settings = {
            "listen.owner" = config.services.nginx.user;
            "listen.group" = config.services.nginx.group;
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.start_servers" = 2;
            "pm.min_spare_servers" = 2;
            "pm.max_spare_servers" = 4;
          };
        };

        # ── PostgreSQL ─────────────────────────────────────────────────────────
        services.postgresql = {
          enable = true;
          ensureDatabases = [ "laravel" ];
          ensureUsers = [{
            name = "laravel";
            ensureDBOwnership = true;
          }];
        };

        # ── Deploy service (git pull + artisan) ────────────────────────────────
        systemd.services.laravel-deploy = {
          description = "Clone or update Laravel app from git";
          after = [ "network-online.target" "postgresql.service" ];
          wants = [ "network-online.target" ];
          # Run once at boot; trigger manually or via CI for deploys
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            User = "laravel";
            RemainAfterExit = true;
          };

          script = ''
            set -euo pipefail

            APP_DIR="${cfg.appDir}"
            REPO="${cfg.repoUrl}"
            BRANCH="${cfg.branch}"

            # Clone if the repo doesn't exist yet
            if [ ! -d "$APP_DIR/.git" ]; then
              ${pkgs.git}/bin/git clone --branch "$BRANCH" "$REPO" "$APP_DIR"
            else
              ${pkgs.git}/bin/git -C "$APP_DIR" fetch origin
              ${pkgs.git}/bin/git -C "$APP_DIR" reset --hard "origin/$BRANCH"
            fi

            # Link the .env file (managed separately, never in git)
            ln -sf "${cfg.envFile}" "$APP_DIR/.env"

            # Install/update Composer dependencies
            ${pkgs.php83Packages.composer}/bin/composer install \
              --no-dev --optimize-autoloader --no-interaction \
              --working-dir="$APP_DIR"

            # Laravel bootstrap
            ${phpPackage}/bin/php "$APP_DIR/artisan" config:cache
            ${phpPackage}/bin/php "$APP_DIR/artisan" route:cache
            ${phpPackage}/bin/php "$APP_DIR/artisan" view:cache
            ${phpPackage}/bin/php "$APP_DIR/artisan" migrate --force

            # Fix permissions
            chmod -R 775 "$APP_DIR/storage" "$APP_DIR/bootstrap/cache"
          '';
        };

        # ── Queue worker ───────────────────────────────────────────────────────
        systemd.services.laravel-queue = {
          description = "Laravel Queue Worker";
          after = [ "laravel-deploy.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = "laravel";
            WorkingDirectory = cfg.appDir;
            ExecStart = "${phpPackage}/bin/php ${cfg.appDir}/artisan queue:work --sleep=3 --tries=3 --max-time=3600";
            Restart = "always";
            RestartSec = "5s";
          };
        };

        # ── Scheduler (replaces cron) ──────────────────────────────────────────
        systemd.timers.laravel-scheduler = {
          wantedBy = [ "timers.target" ];
          timerConfig.OnCalendar = "minutely";
        };

        systemd.services.laravel-scheduler = {
          after = [ "laravel-deploy.service" ];
          serviceConfig = {
            Type = "oneshot";
            User = "laravel";
            ExecStart = "${phpPackage}/bin/php ${cfg.appDir}/artisan schedule:run";
          };
        };
      };
    };
}
