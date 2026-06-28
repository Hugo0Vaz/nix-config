{
  flake.modules.nixos.nixarrMusic =
    { lib, ... }:
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
      # This module ONLY defines options — it does NOT import nixarr or set
      # any nixarr config.  The nixarr module import and configuration live in
      # the companion inline module inside default.nix (at the nixosSystem
      # modules level), because nixarr sets NixOS-level options (like
      # assertions) that conflict with flake-parts' module evaluation.

      options.services.nixarrMusic = {
        enable = mkEnableOption ''
          nixarr music library management stack (Lidarr + Prowlarr + qBittorrent).
        '';

        mediaDir = mkOption {
          type = types.str;
          default = "/data/media";
          description = ''
            Root media directory for nixarr. Must NOT be under a home directory.
          '';
        };

        vpn.enable = mkEnableOption ''
          Route qBittorrent download traffic through a WireGuard VPN.
        '';

        vpn.wgConf = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Path to a WireGuard config file (wg-quick format).
            Example: "/home/hugomvs/Documents/proton-wg.conf"
          '';
        };

        sabnzbd.enable = mkEnableOption ''
          SABnzbd Usenet download client. Requires a Usenet provider account
          (e.g., Newshosting, Eweka, UsenetServer). Configure the provider in
          the SABnzbd web UI at http://localhost:8080 after activation.
        '';
      };
    };
}
