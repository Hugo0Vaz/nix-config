{ config, self, ... }: {

  home.file.".config/waybar/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/waybar/config.jsonc";
  };

  home.file.".config/waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/waybar/style.css";
  };

}
