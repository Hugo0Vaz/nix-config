{ ... }: {
  home.file.".config/hypr/hyprland.conf" = {
    source = ./../../../dotfiles/hyprland/.config/hyprland.conf;
    recursive = true;
  };
}
