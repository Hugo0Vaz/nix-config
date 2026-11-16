{ ... }:

{
  flake.modules.nixos.nix-config-sync-check =
    { config, lib, ... }:
    let
      # Capture NixOS-level options before entering HM module scope, where
      # { config, ... } shadows this binding with the HM config.
      cfg = config.my.nixConfigSyncCheck;
    in
    {
      options.my.nixConfigSyncCheck = {
        repoPath = lib.mkOption {
          type = lib.types.path;
          description = ''
            Path to the nix-config git repository to monitor for sync status.
          '';
        };

        withNotifications = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to emit desktop notifications (via notify-send) when the
            nix-config repo is out of sync with its remote.  Set to true on
            hosts with a graphical session; leave false on headless servers.
          '';
        };

        withTray = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to run a system tray icon (StatusNotifierItem) that shows
            when the repo is out of sync and offers pull/push actions.
            Requires a tray host (DMS, Waybar, KDE, or GNOME with the
            AppIndicator extension).
          '';
        };

        notificationInterval = lib.mkOption {
          type = lib.types.int;
          default = 0;
          description = ''
            Minimum interval in seconds between desktop notifications.
            0 means no throttling (notify every check).  Set to e.g. 1800
            for at most one notification every 30 minutes.
          '';
        };
      };

      config.home-manager.sharedModules = [
        (
          { config, pkgs, lib, ... }:
          let
            syncCheckScript = import ../../_scripts/nix-config-sync-check.nix {
              inherit pkgs;
              repoPath = cfg.repoPath;
              withNotifications = cfg.withNotifications;
              notificationInterval = cfg.notificationInterval;
            };
            statusFile = "${config.home.homeDirectory}/.cache/nix-config-sync-status";
            stateFile = "${config.home.homeDirectory}/.cache/nix-config-sync-state";
            trayScript = import ../../_scripts/nix-config-sync-tray.nix {
              inherit pkgs stateFile;
              repoPath = cfg.repoPath;
              icons = {
                synced = ../../assets/sync-tray-icon-synced.png;
                dirty = ../../assets/sync-tray-icon-dirty.png;
                behind = ../../assets/sync-tray-icon-behind.png;
                ahead = ../../assets/sync-tray-icon-ahead.png;
                diverged = ../../assets/sync-tray-icon-diverged.png;
              };
            };
          in
          {
            home.packages = [ syncCheckScript ] ++ lib.optional cfg.withTray trayScript;

            # ── tray icon: watches the state file written by the check ──

            systemd.user.services.nix-config-sync-tray = lib.mkIf cfg.withTray {
              Unit = {
                Description = "nix-config sync status tray icon";
                After = [ "graphical-session.target" ];
                PartOf = [ "graphical-session.target" ];
              };
              Service = {
                ExecStart = "${trayScript}/bin/nix-config-sync-tray";
                Restart = "on-failure";
                RestartSec = 5;
              };
              Install.WantedBy = [ "graphical-session.target" ];
            };

            # ── systemd user service: runs in background, writes status file ──

            systemd.user.services.nix-config-sync-check = {
              Unit = {
                Description = "Check if nix-config repo is in sync with remote";
                After = [ "graphical-session.target" ];
              };
              Service = {
                Type = "oneshot";
                ExecStart = "${syncCheckScript}/bin/nix-config-sync-check --status-file ${statusFile} --state-file ${stateFile} --notification-interval ${toString cfg.notificationInterval}";
              };
            };

            systemd.user.timers.nix-config-sync-check = {
              Unit.Description = "Periodic nix-config sync check timer";
              Timer = {
                OnCalendar = "*:*:00";
                Persistent = true;
              };
              Install.WantedBy = [ "timers.target" ];
            };

            # ── shell hook: non-blocking — just cats the pre-computed cache ──

            programs.fish.interactiveShellInit = ''
              if test -s ${statusFile}
                cat ${statusFile}
              end
            '';

            programs.bash.bashrcExtra = ''
              [[ $- == *i* ]] && [ -s ${statusFile} ] && cat ${statusFile}
            '';
          }
        )
      ];
    };
}
