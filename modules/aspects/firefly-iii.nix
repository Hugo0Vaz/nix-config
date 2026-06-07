{ lib, ... }:
let
  virtualHost = "firefly.hugovaz.dev";
in
{
  flake.modules.nixos.firefly-iii =
    { config, ... }:
    {
      # ---------------------------------------------------------------------------
      # MariaDB database + user for Firefly III
      # ---------------------------------------------------------------------------
      services.mysql.ensureDatabases = [ "firefly" ];

      # The mysql module's ensureUsers creates unix_socket-authenticated users,
      # but Firefly III needs password authentication.  Create the user with a
      # password from sops on every mysql start (idempotent).
      systemd.services.mysql.postStart = lib.mkAfter ''
        ${config.services.mysql.package}/bin/mysql -e "
          CREATE USER IF NOT EXISTS 'firefly'@'localhost' IDENTIFIED BY '$(cat ${config.sops.secrets.firefly_db_password.path})';
          GRANT ALL PRIVILEGES ON firefly.* TO 'firefly'@'localhost';
          FLUSH PRIVILEGES;
        "
      '';

      # ---------------------------------------------------------------------------
      # Secrets (sops-nix)
      #
      # Two consumers need this password:
      #  1. mysql postStart  → reads the raw sops secret  (owned mysql:mysql)
      #  2. firefly-iii      → reads a sops template copy (owned firefly-iii:nginx)
      #
      # A template is necessary because the firefly-iii-setup service runs with
      # PrivateUsers=true and ProtectSystem=strict, which can interfere with
      # reading host-owned secret files directly.
      # ---------------------------------------------------------------------------
      sops.secrets.firefly_db_password = {
        owner = config.services.mysql.user;
        group = config.services.mysql.group;
        mode = "0400";
      };

      sops.templates.firefly_db_password_content = {
        owner = "firefly-iii";
        group = "nginx";
        mode = "0400";
        content = config.sops.placeholder.firefly_db_password;
      };

      sops.secrets.firefly_app_key = {
        owner = "firefly-iii";
        group = "nginx";
        mode = "0440";
      };

      # ---------------------------------------------------------------------------
      # Firefly III
      # ---------------------------------------------------------------------------
      services.firefly-iii = {
        enable = true;
        enableNginx = true;
        virtualHost = virtualHost;

        settings = {
          APP_ENV = "production";
          APP_KEY_FILE = config.sops.secrets.firefly_app_key.path;
          SITE_OWNER = "admin@hugovaz.dev";
          DB_CONNECTION = "mysql";
          DB_HOST = "localhost";
          DB_PORT = 3306;
          DB_DATABASE = "firefly";
          DB_USERNAME = "firefly";
          DB_PASSWORD_FILE = config.sops.templates.firefly_db_password_content.path;
        };
      };

      # ---------------------------------------------------------------------------
      # Nginx + Let's Encrypt
      # ---------------------------------------------------------------------------
      security.acme = {
        acceptTerms = true;
        defaults.email = lib.mkDefault "admin@hugovaz.dev";
      };

      services.nginx = {
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        virtualHosts.${virtualHost} = {
          enableACME = true;
          forceSSL = true;
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
