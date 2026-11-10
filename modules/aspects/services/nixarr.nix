{
  flake.modules.nixos.nixarr =
    { lib, ... }:
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      # This module only defines options — it does NOT import nixarr or set
      # any nixarr config. The nixarr module import and actual configuration
      # live in an inline module at the nixosSystem `modules` level (see the
      # host's default.nix), because nixarr sets NixOS-level options (like
      # assertions) that conflict with how flake-parts evaluates
      # `flake.modules.nixos.*`.
      options.services.nixarr = {
        enable = mkEnableOption "nixarr media server stack (Sonarr, Radarr, Lidarr, Prowlarr, qBittorrent, Jellyfin).";

        mediaDir = mkOption {
          type = types.str;
          default = "/data/media";
          description = "Root media directory for nixarr. Must NOT be under a home directory.";
        };

        vpn = {
          enable = mkEnableOption "Route qBittorrent download traffic through a WireGuard VPN.";
        };

        sabnzbd.enable = mkEnableOption "SABnzbd Usenet download client (not routed through the VPN).";

        flaresolverr.enable = mkEnableOption "FlareSolverr, a Cloudflare-bypass proxy for Prowlarr indexers.";
      };
    };
}
