{ pkgs, ... }: {

  home.packages = with pkgs; [ ghostty-portable ];

  home.file.".config/ghostty/config" = {
    source = ./../../../dotfiles/ghostty/.config/ghostty/config;
  };
}
