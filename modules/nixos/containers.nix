{ config, lib, ... }: {

  options.monolitoSystem.containers = {
    enable = lib.mkEnableOption "Podman container runtime";
  };

  config = lib.mkIf config.monolitoSystem.containers.enable {

    users.users.${config.monolitoSystem.user.name}.extraGroups = [ "podman" ];

    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
      };
    };
  };

}
