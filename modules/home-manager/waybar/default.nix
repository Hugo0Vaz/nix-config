{ config, flakeRoot, ... }:
{
  home.file.".config/waybar/config.jsonc" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/waybar/config.jsonc";
  };

  home.file.".config/waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/waybar/style.css";
  };
}
