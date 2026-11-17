{
  flake.modules.nixos.downloaders =
    { config
    , inputs
    , lib
    , pkgs
    , ...
    }:
    let
      inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
      cfg = config.services.downloaders;
      # Namespace names are limited to 7 characters by VPN-Confinement.
      namespace = "dlvpn";

      # Runs a command inside the VPN network namespace as the calling user.
      dlVpn = pkgs.writeShellScriptBin "dl-vpn" ''
        set -euo pipefail
        if [ "$#" -eq 0 ]; then
          echo "usage: dl-vpn <command> [args...]" >&2
          exit 1
        fi
        exec sudo ${pkgs.iproute2}/bin/ip netns exec ${namespace} \
          sudo -u "$USER" -- "$@"
      '';
    in
    {
      options.services.downloaders = {
        enable = mkEnableOption "download tools (spotdl, yt-dlp, ...), optionally confined to a VPN.";

        packages = mkOption {
          type = types.listOf types.package;
          default = with pkgs; [ spotdl yt-dlp ];
          description = "Downloader packages to install system-wide.";
        };

        vpn = {
          enable = mkEnableOption "a WireGuard (e.g. ProtonVPN) network namespace for downloaders; run commands in it with `dl-vpn <cmd>`.";

          wgConfSecret = mkOption {
            type = types.str;
            default = "nixarr_vpn_wg_conf";
            description = "Name of the sops secret holding the wg-quick config. Defaults to the secret shared with nixarr.";
          };
        };
      };

      # Reuse the VPN-Confinement module that nixarr already depends on.
      imports = [ inputs.nixarr.inputs.vpnconfinement.nixosModules.default ];

      config = mkIf cfg.enable (mkMerge [
        { environment.systemPackages = cfg.packages; }

        (mkIf cfg.vpn.enable {
          sops.secrets.${cfg.vpn.wgConfSecret}.mode = "0400";

          vpnNamespaces.${namespace} = {
            enable = true;
            wireguardConfigFile = config.sops.secrets.${cfg.vpn.wgConfSecret}.path;
            accessibleFrom = [ ];
          };

          environment.systemPackages = [ dlVpn ];
        })
      ]);
    };
}
