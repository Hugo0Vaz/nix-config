{ config, ... }: {

  home.file.".config/waybar/config" = {
    source = config.lib.file.mkOutOfStoreSymlink (toString ./config);
  };

  home.file.".config/waybar/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink (toString ./style.css);
  };

}
