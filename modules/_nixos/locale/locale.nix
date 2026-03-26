{ config, lib, ... }:
with lib;
{
  options.monolitoSystem.locale = {
    region = mkOption {
      type = types.enum [ "BR" "US" ];
      default = "BR";
      description = "Choose between Brazilian (BR) or US locale settings";
    };
  };

  config = let
    localeSettings = {
      BR = {
        defaultLocale = "pt_BR.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "pt_BR.UTF-8";
          LC_IDENTIFICATION = "pt_BR.UTF-8";
          LC_MEASUREMENT = "pt_BR.UTF-8";
          LC_MONETARY = "pt_BR.UTF-8";
          LC_NAME = "pt_BR.UTF-8";
          LC_NUMERIC = "pt_BR.UTF-8";
          LC_PAPER = "pt_BR.UTF-8";
          LC_TELEPHONE = "pt_BR.UTF-8";
          LC_TIME = "pt_BR.UTF-8";
        };
        keyMap = "br-abnt2";
      };

      US = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };
        keyMap = "us";
      };
    };

    selectedLocale = localeSettings.${config.monolitoSystem.locale.region};
  in {
    i18n.defaultLocale = selectedLocale.defaultLocale;
    i18n.extraLocaleSettings = selectedLocale.extraLocaleSettings;
    console.keyMap = selectedLocale.keyMap;
  };
}
