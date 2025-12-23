{ pkgs, config, self, ... }: {

  home.file.".config/waybar/config" = {
    source =  ./waybar/config.jsonc;
  };

  home.file.".config/waybar/style.css" = {
    source = ./waybar/style.css;
  };


  home.packages = with pkgs; [
    gnome-calendar
  ];

}
