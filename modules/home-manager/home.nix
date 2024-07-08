{ config, pkgs, inputs, ... }:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  home.stateVersion = "24.05"; # Did you read the comment?

  programs.home-manager.enable = true;

  home.username = "hugomvs";
  home.homeDirectory = "/home/hugomvs";

  home.packages = with pkgs; [
    neovim
    gcc
    go
    php
    lua
    nodejs
    python3
    kotlin
    openjdk
    php83Packages.composer
    lua-language-server
    oh-my-zsh
    fzf-zsh
    nixfmt-classic
    nil
  ];

  imports = [
    ./cli
    ./gui
    ./shell
    ./lang
  ];
}
