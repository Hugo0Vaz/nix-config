{ pkgs, ... }: {
  home.packages = with pkgs; [
    dbeaver-bin
    jetbrains.idea-community-bin

    opera
    google-chrome
    microsoft-edge

    obsidian

    vscodium
    # FIXME: for some weird reason vscode causes an derivation issue
    # vscode
  ];

  imports = [
    ./alacritty.nix
    ./wezterm.nix
    ./kitty.nix
    ./dunst.nix
    ./wofi.nix
    ./hyprland.nix
    ./waybar.nix
  ];
}
