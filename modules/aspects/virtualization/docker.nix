{
  flake.modules.nixos.docker =
    { pkgs, ... }:
    {
      virtualisation = {
        containers.enable = true;
        docker = {
          enable = true;
          enableOnBoot = true;
        };
      };

      # Winboat's prerequisite check looks for the `docker-compose` binary.
      # This package also installs itself as a docker CLI plugin so that
      # `docker compose -f ... up -d` works.
      environment.systemPackages = with pkgs; [
        docker-compose
      ];
    };
}
