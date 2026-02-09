# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  system.stateVersion = "24.05";
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos
  ];

  # Path to the flake repository for mkOutOfStoreSymlink
  monolitoSystem.flakeRoot = "/home/hugomvs/Projetos/nix-config";

  programs.fish.enable = true;

  networking.hostName = "nixos-notebook";

  monolitoSystem.user = {
    name = "hugomvs";
    description = "Hugo Martins Vaz Silva";
    userShell = pkgs.fish;
  };
  
  monolitoSystem.kbd.region = "BR";
  
  monolitoSystem.desktop = {
    enable = "hyprland";
  };
}
