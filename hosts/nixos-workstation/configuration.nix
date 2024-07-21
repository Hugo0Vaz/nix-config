{ config, pkgs, options, inputs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    nix-output-monitor
  ];

  programs.firefox.enable = true;

  imports = [
    ./hardware-configuration.nix

    ./../../modules/nixos/audio.nix
    ./../../modules/nixos/boot.nix
    ./../../modules/nixos/desktop.nix
    ./../../modules/nixos/docker.nix
    ./../../modules/nixos/locale.nix
    ./../../modules/nixos/nvidia.nix
    ./../../modules/nixos/printing.nix
    ./../../modules/nixos/time.nix
    ./../../modules/nixos/user.nix
  ];
}
