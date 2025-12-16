{ config, self, pkgs, ... }: {

  home.packages = with pkgs; [
    ydotool
    wofi
    kdePackages.dolphin
    grim          # Screenshot tool for Wayland
    slurp         # Select a region in Wayland
    wl-clipboard  # Wayland clipboard utilities
    pinta         # Image editor
  ];

  home.pointerCursor = {
    package = pkgs.kdePackages.breeze;
    name = "breeze_cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.file.".config/hypr/hyprland.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/hyprland/hyprland.conf";
  };
}
