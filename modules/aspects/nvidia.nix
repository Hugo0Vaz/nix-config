{
  flake.modules.nixos.nvidia =
    { config, ... }:
    {
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
