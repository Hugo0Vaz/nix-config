{ config, flakeRoot, ... }:
{
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };
  };

  home.file.".config/wofi/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/wofi/style.css";
  };
}
