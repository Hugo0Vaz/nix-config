{ pkgs, ... }: {
  home.packages = with pkgs; [
    dbeaver-bin
    jetbrains.idea-community-bin

    google-chrome

    obsidian

    obs-studio
    vlc
    vivaldi

    localsend

    drawio
  ];

  imports = [
    ./alacritty.nix
    ./wezterm.nix
    ./kitty.nix
    ./dunst.nix
    ./wofi.nix
    ./hyprland.nix
    ./waybar.nix
    ./ghostty.nix
  ];
}
