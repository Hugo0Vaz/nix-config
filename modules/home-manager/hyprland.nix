{ config, self, ... }: {

  home.file.".config/hypr/hyprland.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/hyprland/hyprland.conf";
  };
}
