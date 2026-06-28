{ inputs, lib, ... }:
let
  # Inline NixOS module: imports nixarr and configures it based on
  # config.services.nixarrMusic.  This lives at the nixosSystem modules
  # level so flake-parts never processes nixarr's internal assertions.
  nixarrMusicModule = { config, pkgs, ... }:
    let
      cfg = config.services.nixarrMusic;
    in
    {
      imports = [
        inputs.nixarr.nixosModules.default
      ];

      config = lib.mkIf cfg.enable {
        # FlareSolverr: bypasses CloudFlare on indexers for Prowlarr
        systemd.tmpfiles.rules = [
          "d /data/.state/flaresolverr 0750 flaresolverr flaresolverr - -"
        ];

        users.users.flaresolverr = {
          isSystemUser = true;
          group = "flaresolverr";
        };
        users.groups.flaresolverr = { };

        systemd.services.flaresolverr = {
          description = "FlareSolverr - CloudFlare bypass proxy";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Type = "simple";
            User = "flaresolverr";
            Group = "flaresolverr";
            ExecStart = "${pkgs.flaresolverr}/bin/flaresolverr";
            Restart = "on-failure";
            RestartSec = "10s";
            Environment = [
              "LOG_LEVEL=info"
              "PORT=8191"
              "HOME=/data/.state/flaresolverr"
            ];
          };
        };

        services.prowlarr.settings.auth.required = "DisabledForLocalAddresses";
        services.lidarr.settings.auth.required = "DisabledForLocalAddresses";

        nixarr = {
          enable = true;
          mediaDir = cfg.mediaDir;

          vpn = lib.mkIf cfg.vpn.enable {
            enable = true;
            wgConf = cfg.vpn.wgConf;
          };

          lidarr = {
            enable = true;
            openFirewall = false;
          };

          prowlarr = {
            enable = true;
            openFirewall = false;

            settings-sync = {
              lidarr.enable = true;
              indexers = [ ];
              tags = [ ];
            };
          };

          qbittorrent = {
            enable = true;
            openFirewall = false;
            qui.enable = true;
            vpn.enable = cfg.vpn.enable;
            # Accept legal notice so the web API starts without manual intervention
            extraConfig.LegalNotice.Accepted = true;
          };

          sabnzbd = lib.mkIf cfg.sabnzbd.enable {
            enable = true;
            openFirewall = false;
            # Usenet is SSL-encrypted, no VPN needed
          };
        };
      };
    };
in
{
  flake.nixosConfigurations = {
    nixos-notebook = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.self.modules.nixos.nixosNotebookConfiguration
        nixarrMusicModule
      ];
    };
  };
}
