{ pkgs, config, self, lib, ... }:

let
  isSmallScreen = config.hyprland.uiSize == "small";
  configFile = if isSmallScreen then ./waybar/config-small.jsonc else ./waybar/config.jsonc;
  styleFile = if isSmallScreen then ./waybar/style-small.css else ./waybar/style.css;
in

{
  home.file.".config/waybar/config" = {
    source = configFile;
  };

  home.file.".config/waybar/style.css" = {
    source = styleFile;
  };

  home.packages = with pkgs; [
    gnome-calendar
  ];
}
