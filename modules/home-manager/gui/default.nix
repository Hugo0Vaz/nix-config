{ pkgs, ... }: {
  home.packages = with pkgs; [
    dbeaver-bin
    jetbrains.idea-community-bin

    opera
    google-chrome

    obsidian

    vscodium
    # FIXME: for some weird reason vscode causes an derivation issue
    # vscode
  ];

  imports = [ ./alacritty.nix ./wezterm.nix ];
}
