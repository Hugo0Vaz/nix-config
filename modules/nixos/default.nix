{...}:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./boot
    ./desktop
    ./gpu
    ./locale
    ./networking
    ./user
    ./virtualization
  ];
}
