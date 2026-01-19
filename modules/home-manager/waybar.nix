{ pkgs, config, self, lib, ... }:
{
  home.file.".config/waybar/config" = {
    source = ./waybar/config.jsonc;
  };

  home.file.".config/waybar/style.css" = {
    source = ./waybar/style.css;
  };
}
