{ ... }: {
  home.file.".config/hypr/hyprland.conf" = {
    source = ./../../../dotfiles/hyprland/.config/hypr/hyprland.conf;
    recursive = true;
  };
}
