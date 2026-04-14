{
  flake.modules.nixos.grub =
    { pkgs, ... }:
    {
      boot.loader.grub.enable = true;
    };
}
