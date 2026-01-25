{ config, flakeRoot, ... }:
{
  home.file.".config/waybar/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/waybar/config";
  };

  home.file.".config/waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/waybar/style.css";
  };
}
