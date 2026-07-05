{
  flake.modules.nixos.winboat =
    { pkgs, lib, ... }:
    {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isx86_64;
          message = "winboat only supports x86_64-linux";
        }
      ];

      # Winboat expects the user to be in the `docker` group, but this
      # host runs podman (with dockerCompat), which does not create a
      # `docker` group. Define it explicitly so users listed in
      # `extraGroups = [ "docker" ... ]` are actually added, instead of
      # winboat imperatively re-adding them on every boot.
      users.groups.docker = { };

      environment.systemPackages = with pkgs; [
        winboat
        freerdp
      ];
    };
}
