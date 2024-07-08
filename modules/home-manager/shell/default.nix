{pkgs, ...}:
{
    home.packages = with pkgs; [
    fzf-zsh
    fish
    zsh
  ];
}
