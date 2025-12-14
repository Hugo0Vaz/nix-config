{ config, self, pkgs, ... }: {

  home.packages = with pkgs; [ ghostty ];

  home.file.".config/ghostty/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${self}/modules/home-manager/ghostty/config";
  };
}
