{ ... }: {
  programs.wezterm = {
    enable = true;
    extraConfig =
      builtins.readFile ./../../../dotfiles/wezterm/.config/wezterm/wezterm.lua;
  };
}
