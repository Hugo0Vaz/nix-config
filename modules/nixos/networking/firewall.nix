{ ... }: {
  networking.firewall.enable = true;  # Ensure the firewall is enabled
  networking.firewall.allowedTCPPorts = [ 8081 24800 9090 ];  # Allow TCP traffic on port 8081
  networking.firewall.allowedUDPPorts = [ 8081 24800 9090 ];  # Allow UDP traffic on port 8081
}
