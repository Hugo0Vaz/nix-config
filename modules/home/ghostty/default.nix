{ pkgs, ... }: {

  home.packages = with pkgs; [ ghostty ];

  home.file.".config/ghostty/config" = {
    source = ./ghostty/config;
  };
}
