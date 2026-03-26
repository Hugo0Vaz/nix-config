{ ... }:
{
  home.file.".config/waybar/config.jsonc" = {
    source = ./config.jsonc;
  };

  home.file.".config/waybar/style.css" = {
    source = ./style.css;
  };
}
