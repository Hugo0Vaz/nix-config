{ config, flakeRoot, pkgs, ... }: {

  home.packages = with pkgs; [ ghostty ];

  home.file.".config/ghostty/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${flakeRoot}/modules/home-manager/ghostty/config";
  };
}
