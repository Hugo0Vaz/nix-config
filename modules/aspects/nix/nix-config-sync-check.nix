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
      };

      config.home-manager.sharedModules = [
        (
          { config, pkgs, ... }:
          let
            syncCheckScript = import ../_scripts/nix-config-sync-check.nix {
              inherit pkgs;
              repoPath = cfg.repoPath;
              withNotifications = cfg.withNotifications;
            };
            statusFile = "${config.home.homeDirectory}/.cache/nix-config-sync-status";
          in
          {
            home.packages = [ syncCheckScript ];

            # ── systemd user service: runs in background, writes status file ──

            systemd.user.services.nix-config-sync-check = {
              Unit = {
                Description = "Check if nix-config repo is in sync with remote";
                After = [ "graphical-session.target" ];
              };
              Service = {
                Type = "oneshot";
                ExecStart = "${syncCheckScript}/bin/nix-config-sync-check --status-file ${statusFile}";
              };
            };

            systemd.user.timers.nix-config-sync-check = {
              Unit.Description = "Periodic nix-config sync check timer";
              Timer = {
                OnCalendar = "*:0,30:00";
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
