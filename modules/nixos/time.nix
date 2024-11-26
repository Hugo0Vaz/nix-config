{ config, options, ... }:

{
  networking.hostName = "nixos-workstation";
  networking.networkmanager.enable = true;
  networking.timeServers = options.networking.timeServers.default
    ++ [ "a.ntp.br" ];

  time.timeZone = "America/Sao_Paulo";

  services.geoclue2.enable = true;
  services.ntp.enable = true;
  services.localtimed.enable = true;
  services.timesyncd.enable = true;
}
