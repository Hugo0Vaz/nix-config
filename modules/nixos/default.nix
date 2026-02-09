{...}:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Garbage collection configuration
  nix.gc = {
    automatic = true;
    dates = "biweekly";
    options = "--delete-older-than 14d";
  };

  imports = [
    ../common/flake-root.nix
    ./boot
    ./desktop
    ./gpu
    ./locale
    ./networking
    ./user
    ./virtualization
  ];
}
