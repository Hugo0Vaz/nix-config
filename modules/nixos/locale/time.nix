{ config, lib, options, ... }:
with lib;
{
  options.monolitoSystem.time = {
    region = mkOption {
      type = types.enum [ "BR" "US-East" "US-West" "US-Central" "US-Mountain" ];
      default = "BR";
      description = "Choose region for time settings";
    };

    enableGeoclue = mkOption {
      type = types.bool;
      default = true;
      description = "Enable geoclue2 for location services";
    };

    enableLocaltime = mkOption {
      type = types.bool;
      default = true;
      description = "Enable localtimed for automatic timezone updates";
    };
  };

  config = let
    timeSettings = {
      BR = {
        timeZone = "America/Sao_Paulo";
        timeServers = [ "a.ntp.br" "b.ntp.br" "c.ntp.br" ];
      };

      US-East = {
        timeZone = "America/New_York";
        timeServers = [ "time.nist.gov" "time-a-g.nist.gov" ];
      };

      US-West = {
        timeZone = "America/Los_Angeles";
        timeServers = [ "time.nist.gov" "time-a-g.nist.gov" ];
      };

      US-Central = {
        timeZone = "America/Chicago";
        timeServers = [ "time.nist.gov" "time-a-g.nist.gov" ];
      };

      US-Mountain = {
        timeZone = "America/Denver";
        timeServers = [ "time.nist.gov" "time-a-g.nist.gov" ];
      };
    };

    selectedTime = timeSettings.${config.monolitoSystem.time.region};
  in {
    time.timeZone = mkForce selectedTime.timeZone;
    services.geoclue2.enable = config.monolitoSystem.time.enableGeoclue;
    services.localtimed.enable = config.monolitoSystem.time.enableLocaltime;
    networking.timeServers = options.networking.timeServers.default
      ++ selectedTime.timeServers;

    services.timesyncd.enable = true;
    services.ntp.enable = true;
  };
}
