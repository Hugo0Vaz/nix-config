{ pkgs, ... }: {

  home.packages = with pkgs; [ ghostty ];

  home.file.".config/ghostty/config" = {
    source = ./../../../dotfiles/ghostty/.config/ghostty/config;
  };
}
