{ lib, ... }:
with lib;
{
  options.monolitoSystem.desktop.enable = mkOption {
    type = types.enum [ "plasma" "gnome" "hyprland" "none" ];
    default = "none";
    description = "Which desktop environment to use";
  };

  imports = [
    ./common.nix
    ./plasma.nix
    ./gnome.nix
    ./hyprland.nix
    ./dark-theme.nix
  ];
}
