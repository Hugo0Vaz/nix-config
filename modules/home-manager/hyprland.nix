{ config, self, pkgs, ... }: {

  home.packages = with pkgs; [
    ydotool
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
