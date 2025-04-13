{ pkgs, ... }: {
  home.packages = with pkgs; [
    dbeaver-bin
    jetbrains.idea-community-bin

    opera
    google-chrome
    microsoft-edge

    obsidian

    obs-studio
    vlc
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
