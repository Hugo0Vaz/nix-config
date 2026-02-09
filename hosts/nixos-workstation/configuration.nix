{ pkgs, ... }: {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos
  ];

  # Path to the flake repository for mkOutOfStoreSymlink
  monolitoSystem.flakeRoot = "/home/hugomvs/Projetos/nix-config";

  programs.fish.enable = true;

  networking.hostName = "nixos-workstation";

  monolitoSystem.user = {
    name = "hugomvs";
    description = "Hugo Martins Vaz Silva";
    userShell = pkgs.fish;
  };

  monolitoSystem.kbd.region = "BR";

  monolitoSystem.desktop = {
    enable = "hyprland";
  };

  monolitoSystem.containers.enable = true;
}
