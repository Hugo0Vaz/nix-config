{ pkgs, ... }: {
  home.packages = with pkgs; [
    figlet
    tree
    zip
    unzip
    fzf
    rclone
    fd
    ripgrep
    lazygit
    nix-direnv
    zoxide
    file
    aider-chat
    gh
    pass
  ];

  programs.eza.enable = true;

  imports = [ ./neovim.nix ./tmux.nix ./git.nix ];
}
