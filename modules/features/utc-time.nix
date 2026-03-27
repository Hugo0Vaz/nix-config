{
  flake.modules.nixos.utc-time =
    {
      time.timeZone = "UTC";

      services.geoclue2.enable = false;
      services.localtimed.enable = false;

      networking.timeServers = [
        "0.pool.ntp.org"
        "1.pool.ntp.org"
        "2.pool.ntp.org"
        "3.pool.ntp.org"
      ];

      services.timesyncd.enable = true;
      services.ntp.enable = false;
    };
}
