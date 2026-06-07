{ ... }:
{
  flake.modules.nixos.mariadb =
    { pkgs, ... }:
    {
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
      };
    };
}
