{ ... }: {

  home.file.".config/waybar/" = {
    source = ./../../../dotfiles/waybar/.config/waybar;
    recursive = true;
  };

}
