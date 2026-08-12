{
  flake.modules.nixos.nvidia =
    { config, lib, ... }:
    {
      hardware.graphics.enable = true;

      hardware.nvidia-container-toolkit.enable = lib.mkDefault true;

      virtualisation.vmVariant = {
        hardware.nvidia-container-toolkit.enable = lib.mkVMOverride false;
      };

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
