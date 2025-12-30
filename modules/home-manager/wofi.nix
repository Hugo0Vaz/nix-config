{ config, self, pkgs, lib, ... }:

let
  isSmallScreen = config.hyprland.uiSize == "small";
  wofiWidth = if isSmallScreen then 480 else 600;
  wofiHeight = if isSmallScreen then 320 else 400;
  imageSize = if isSmallScreen then 32 else 40;
in

{
  programs.wofi = {
    enable = true;
    settings = {
      width = wofiWidth;
      height = wofiHeight;
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
      image_size = imageSize;
      gtk_dark = true;
    };
  };

  home.file.".config/wofi/style.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/wofi/style.css";
  };
}
