{ lib, ... }:

let
  repoPath = "/home/hugomvs/Projetos/nix-config";
in
{
  flake.modules.nixos.nix-config-sync-check =
    { inputs, config, pkgs, lib, ... }:
    {
      options.my.nixConfigSyncCheck.withNotifications = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to emit desktop notifications (via notify-send) when the
          nix-config repo is out of sync with its remote.  Set to true on
          hosts with a graphical session; leave false on headless servers.
        '';
      };

      config.home-manager.sharedModules = [
        (
          { ... }:
          {
            home.packages = [
              (import ../_scripts/nix-config-sync-check.nix {
                inherit pkgs;
                inherit repoPath;
                withNotifications = config.my.nixConfigSyncCheck.withNotifications;
              })
            ];

            programs.fish.interactiveShellInit = ''
              nix-config-sync-check
            '';

            programs.bash.bashrcExtra = ''
              # Run nix-config sync check in interactive sessions only
              [[ $- == *i* ]] && nix-config-sync-check
            '';
          }
        )
      ];
    };
}
