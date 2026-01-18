{ config, lib, ... }: {

  options.monolitoSystem.kbd = {

    region = lib.mkOption {
      type = lib.types.enum [ "BR" "US" ];
      default = "BR";
      description = "Choose region for keyboard settings";
    };

  };

  config = let
    kbdSettings = {
      BR = {
        layout = "br";
        variant = "abnt2";
        model = "abnt2";
      };

      US = {
        layout = "us";
        variant = "";
        model = "pc104";
      };
    };

    selectedKbd = kbdSettings.${config.monolitoSystem.kbd.region};
  in {
    services.xserver.xkb = {
      layout = selectedKbd.layout;
      variant = selectedKbd.variant;
      model = selectedKbd.model;
    };
  };
}
