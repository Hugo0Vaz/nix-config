# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos
  ];

  programs.fish.enable = true;

  networking.hostName = "nixos-workstation";

  monolitoSystem.user = {
    name = "hugomvs";
    description = "Hugo Martins Vaz Silva";
    userShell = pkgs.fish;
  };
  
  monolitoSystem.desktop = {
    enable = "hyprland";
  };
}
