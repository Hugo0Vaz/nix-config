{ inputs, lib, ... }:
let
  nixarrModule =
    { config, ... }:
    let
      cfg = config.services.nixarr;
    in
    {
      imports = [ inputs.nixarr.nixosModules.default ];

      config = lib.mkIf cfg.enable {
        sops.secrets.nixarr_vpn_wg_conf = lib.mkIf cfg.vpn.enable {
          mode = "0400";
        };

        # Required by nixarr's Prowlarr settings-sync assertions: apps it syncs
        # indexers/config to must not require interactive login. Safe here
        # because these services are only reachable via Tailscale/LAN
        # (openFirewall = false everywhere below), and Tailscale's CGNAT range
        # (100.64.0.0/10) is treated as a "local address" by these apps.
        services.prowlarr.settings.auth.required = "DisabledForLocalAddresses";
        services.sonarr.settings.auth.required = "DisabledForLocalAddresses";
        services.radarr.settings.auth.required = "DisabledForLocalAddresses";
        services.lidarr.settings.auth.required = "DisabledForLocalAddresses";

        nixarr = {
          enable = true;
          mediaDir = cfg.mediaDir;

          vpn = lib.mkIf cfg.vpn.enable {
            enable = true;
            wgConf = config.sops.secrets.nixarr_vpn_wg_conf.path;
          };

          sonarr = {
            enable = true;
            openFirewall = false;
          };

          radarr = {
            enable = true;
            openFirewall = false;
          };

          lidarr = {
            enable = true;
            openFirewall = false;
          };

          prowlarr = {
            enable = true;
            openFirewall = false;
            settings-sync.enable-nixarr-apps = true;
          };

          jellyfin = {
            enable = true;
            openFirewall = false;
          };

          qbittorrent = {
            enable = true;
            openFirewall = false;
            qui.enable = true;
            vpn.enable = cfg.vpn.enable;
            extraConfig.LegalNotice.Accepted = true;
          };

          sabnzbd = lib.mkIf cfg.sabnzbd.enable {
            enable = true;
            openFirewall = false;
          };
        };

        # Not part of nixarr itself — a plain native NixOS module. Prowlarr
        # needs it registered manually as an Indexer Proxy (Settings →
        # Indexers → Indexer Proxies → FlareSolverr, http://localhost:8191),
        # since nixarr has no declarative sync for that.
        services.flaresolverr = lib.mkIf cfg.flaresolverr.enable {
          enable = true;
        };
      };
    };
in
{
  flake.nixosConfigurations = {
    nixos-workstation = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.self.modules.nixos.nixosWorkstationConfiguration
        nixarrModule
      ];
    };
  };
}
