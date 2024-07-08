{pkgs, ...}:
{
  home.packages = with pkgs; [
    dbeaver-bin
    jetbrains.idea-community-bin

    opera
    google-chrome

    obsidian

    vscodium

    wezterm
    alacritty
  ];
}
