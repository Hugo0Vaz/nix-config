{ pkgs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  home.stateVersion = "24.05"; # Did you read the comment?

  imports = [
    ../../modules/home-manager
  ];

  # Path to the flake repository for mkOutOfStoreSymlink
  monolitoSystem.flakeRoot = "/home/hugom/Projetos/nix-config";

  programs.home-manager.enable = true;

  home.username = "hugom";
  home.homeDirectory = "/home/hugom";
}
