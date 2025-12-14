{ config, lib, ... }: {

  options.monolitoSystem.containers = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Podman container runtime";
    };

    enableNvidia = lib.mkOption {
      type = lib.types.bool;
      default = config.hardware.nvidia.package != null;
      description = "Enable NVIDIA container support";
    };
  };

  config = lib.mkIf config.monolitoSystem.containers.enable {

    users.users.${config.monolitoSystem.user.name}.extraGroups = config.monolitoSystem.user.extraGroups ++ [ "podman" ];

    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
      };
    };

    hardware.nvidia-container-toolkit.enable = lib.mkIf config.monolitoSystem.containers.enableNvidia true;
  };

}
