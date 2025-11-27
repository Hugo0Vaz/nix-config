{ config, lib, pkgs, ... }:
with lib;
{
  options.monolitoSystem.tailscale = {
    enable = lib.mkEnableOption "tailscale";
  };

  config = lib.mkIf config.monolitoSystem.tailscale.enable {

    services.tailscale.enable = true;

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ 41641 ];
    };

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = with pkgs; ''
        sleep 2
        status=$(${tailscale}/bin/tailscale status --json | ${jq}/bin/jq -r '.BackendState')
        if [ "$status" = "Running" ]; then
          echo "Tailscale is already connected"
        else
          echo "Connecting to Tailscale..."
          ${tailscale}/bin/tailscale up
        fi
      '';
    };
  };
}
