{
  flake.modules.nixos.local-time =
    {
      time.timeZone = "America/Sao_Paulo";
      services.geoclue2.enable = true;
      services.localtimed.enable = true;
      networking.timeServers = [ "a.ntp.br" "b.ntp.br" "c.ntp.br" ];
      services.timesyncd.enable = true;
      services.ntp.enable = true;
    };
}
