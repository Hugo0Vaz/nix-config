{ pkgs, ... }: {

  home.packages = with pkgs; [ networkmanagerapplet waybar ];

  home.file.".config/hypr/hyprland.conf" = {
    source = ./hyprland.conf;
    recursive = true;
  };
}
