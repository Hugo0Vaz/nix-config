{
  flake.modules.nixos.pcloud =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.pcloud ];
    };
}