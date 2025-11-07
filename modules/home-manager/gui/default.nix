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

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

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
