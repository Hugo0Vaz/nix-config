{
  flake.modules.nixos.winboat =
    { inputs, pkgs, lib, ... }:
    let
      launchScript = import ../_scripts/winboat-launch.nix { inherit pkgs; };
      syncScript = import ../_scripts/winboat-sync-apps.nix { inherit pkgs; };
    in
    {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isx86_64;
          message = "winboat only supports x86_64-linux";
        }
      ];

      # Winboat expects the user to be in the `docker` group, but this
      # host runs podman (with dockerCompat), which does not create a
      # `docker` group. Define it explicitly so users listed in
      # `extraGroups = [ "docker" ... ]` are actually added, instead of
      # winboat imperatively re-adding them on every boot.
      users.groups.docker = { };

      environment.systemPackages = with pkgs; [
        winboat
        freerdp
        jq
        launchScript
        syncScript
      ];

      home-manager.sharedModules = [
        inputs.self.modules.homeManager.winboat
      ];
    };

  flake.modules.homeManager.winboat =
    { pkgs, ... }:
    let
      syncScript = import ../_scripts/winboat-sync-apps.nix { inherit pkgs; };
    in
    {
      # ── systemd user service: keeps ~/.local/share/applications/winboat-*.desktop
      #    in sync with the WinBoat guest API's /apps endpoint so DMS (and any
      #    other XDG launcher) shows Windows apps. No-op while the container is
      #    down (the script health-checks before doing anything). ──────────────
      systemd.user.services.winboat-apps-sync = {
        Unit = {
          Description = "Sync WinBoat Windows apps to XDG desktop entries";
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${syncScript}/bin/winboat-sync-apps";
        };
      };

      systemd.user.timers.winboat-apps-sync = {
        Unit.Description = "Periodic WinBoat app launcher sync";
        Timer = {
          OnBootSec = "2min";
          OnUnitActiveSec = "10min";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
