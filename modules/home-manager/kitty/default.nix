{ config, flakeRoot, pkgs, ... }: {

  home.packages = with pkgs; [ kitty ];

  home.file.".config/kitty/kitty.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/kitty/kitty.conf";
  };
}
