{
  flake.modules.nixos.podman =
    { config, lib, ... }:
    {
      virtualisation = {
        containers.enable = true;
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      hardware.nvidia-container-toolkit.enable =
        lib.mkIf (config.hardware.nvidia.package != null) true;
    };
}
