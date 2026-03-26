{ config, lib, ... }: {

  options.monolitoSystem.gpu = {
    # TODO: implement options for other gpu vendors

    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GPU hardware acceleration";
    };
  };

  config = lib.mkIf config.monolitoSystem.gpu.enable {

    hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {

      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = false;

      # set it to `true` to enable Nvidia Open Souce Drivers (not Nouveau)
      open = false;

      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

}
